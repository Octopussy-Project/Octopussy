#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Logs.t - Octopussy Source Code Checker for Octopussy::Logs

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 14;

use Octopussy;
use Octopussy::Device;
use Octopussy::Logs;

Readonly my $PREFIX    => 'Octo_TEST_';
Readonly my $DEVICE    => "${PREFIX}Device";
Readonly my $SERVICE   => "${PREFIX}Service";
Readonly my $EXTRACTOR => '/usr/sbin/octo_extractor';
Readonly my $DIR_LOGS  => Octopussy::Directory('data_logs');
Readonly my $BEGIN     => '201001010000';
Readonly my $END       => '201001010029';
Readonly my $YEAR      => '2010';
Readonly my $MONTH     => '01';
Readonly my $DAY       => '01';
Readonly my $OUTPUT    => 'output_file.txt';
Readonly my $CMDLINE_DEV_SVC =>
qq(--device "${DEVICE}_1" --device "${DEVICE}_2" --service "${SERVICE}_1" --service "${SERVICE}_2");
Readonly my $CMDLINE_LEVEL_TAXO_ID =>
  qq(--loglevel "-ANY-" --taxonomy "-ANY-" --msgid "-ANY-");
Readonly my $CMDLINE_PERIOD => qq(--begin $BEGIN --end $END);
Readonly my $RE_CMDLINE =>
qr{^$EXTRACTOR $CMDLINE_DEV_SVC $CMDLINE_LEVEL_TAXO_ID $CMDLINE_PERIOD.*--output "$OUTPUT"};

=head2 Generate_Fake_Logs_Files()

=cut

sub Generate_Fake_Logs_Files
{
  system "mkdir -p $DIR_LOGS/$DEVICE/Incoming/2010/01/01/";
  system "mkdir -p $DIR_LOGS/$DEVICE/Unknown/2010/01/01/";
  system "mkdir -p $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/";
  for (my $i = 0 ; $i <= 59 ; $i++)
  {
    my $minute = sprintf '%02d', $i;
    system "touch $DIR_LOGS/$DEVICE/Incoming/2010/01/01/msg_00h${minute}.log";
    my $data = '';
    for (my $i2 = 0 ; $i2 <= 99 ; $i2++) { $data .= "line $i2\n"; }
    if (defined open my $FILE,
      '|-',
      "gzip >> $DIR_LOGS/$DEVICE/Unknown/2010/01/01/msg_00h${minute}.log.gz")
    {
      print {$FILE} $data;
      close $FILE;
    }
    system
      "touch $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_00h${minute}.log.gz";
    system
      "touch $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_01h${minute}.log.gz";
  }
}

my ($d_incoming, $d_unknown) = Octopussy::Logs::Init_Directories($DEVICE);
my $dirs_created = 1 if (-d $d_incoming && -d $d_unknown);
ok(
  $d_incoming =~ /\/$DEVICE\/Incoming\//
    && $d_unknown =~ /\/$DEVICE\/Unknown\//
    && $dirs_created,
  'Octopussy::Logs::Init_Directories()'
);

Octopussy::Logs::Remove_Directories($DEVICE);
ok((!-d $d_incoming && !-d $d_unknown),
  'Octopussy::Logs::Remove_Directories()');

Generate_Fake_Logs_Files();

my %start  = (year => 2010, month => 1, day => 1, hour => 0, min => 0);
my %finish = (year => 2010, month => 1, day => 1, hour => 0, min => 29);
my $start_num = sprintf '%04d%02d%02d%02d%02d',
  $start{year}, $start{month}, $start{day}, $start{hour}, $start{min};
my $finish_num = sprintf '%04d%02d%02d%02d%02d',
  $finish{year}, $finish{month}, $finish{day}, $finish{hour}, $finish{min};

my @files_ymd = Octopussy::Logs::Files_Year_Month_Day(\%start, \%finish,
  "$DIR_LOGS/$DEVICE/$SERVICE", '2010');
ok(scalar @files_ymd == 120, 'Octopussy::Logs::Files_Year_Month_Day()');
my @files_ymdhm =
  Octopussy::Logs::Files_Year_Month_Day_Hour_Min("$DIR_LOGS/$DEVICE/$SERVICE",
  $start_num, $finish_num, \@files_ymd);
ok(scalar @files_ymdhm == 30,
  'Octopussy::Logs::Files_Year_Month_Day_Hour_Min()');

# Need to create Device/Service
Octopussy::Device::New({name => $DEVICE, address => '1.2.3.4'});
Octopussy::Device::Add_Service($DEVICE, $SERVICE);

my $list_files =
  Octopussy::Logs::Files([$DEVICE], [$SERVICE], \%start, \%finish);
ok(scalar @{$list_files} == 30, 'Octopussy::Logs::Files()');

my $avail = Octopussy::Logs::Availability($DEVICE, \%start, \%finish);
ok(
  $avail->{$SERVICE}{'01'}{'01'}{'00'}{'00'}
    && $avail->{$SERVICE}{'01'}{'01'}{'00'}{'29'},
  'Octopussy::Logs::Availability()'
);

my ($hash_files, $nb_files) =
  Octopussy::Logs::Minutes_Hash([$DEVICE], [$SERVICE], \%start, \%finish);
ok($nb_files == 30 && defined $hash_files->{201001010029},
  'Octopussy::Logs::Minutes_Hash()');

($list_files, $nb_files) =
  Octopussy::Logs::Get_TimePeriod_Files([$DEVICE], [$SERVICE], $BEGIN, $END);
ok($nb_files == 30, 'Octopussy::Logs::Get_TimePeriod_Files()');

my @files_incoming = Octopussy::Logs::Incoming_Files($DEVICE);
ok(scalar @files_incoming == 60, 'Octopussy::Logs::Incoming_Files');

my @files_unknown = Octopussy::Logs::Unknown_Files($DEVICE);
ok(scalar @files_unknown == 60, 'Octopussy::Logs::Unknown_Files');

my $nb_lines_unknown = Octopussy::Logs::Unknown_Number($DEVICE);
ok($nb_lines_unknown == 100, 'Octopussy::Logs::Unknown_Number');

my $nb_removed = Octopussy::Logs::Remove($DEVICE, 'line 9\d+');
ok($nb_removed == 600, 'Octopussy::Logs::Remove()');

Octopussy::Logs::Remove_Minute($DEVICE, $YEAR, $MONTH, $DAY, '00', '00');
@files_unknown = Octopussy::Logs::Unknown_Files($DEVICE);
ok(scalar @files_unknown == 59, 'Octopussy::Logs::Remove_Minute()');

my %conf_extract = (
  devices   => ["${DEVICE}_1",  "${DEVICE}_2"],
  services  => ["${SERVICE}_1", "${SERVICE}_2"],
  loglevel  => '-ANY-',
  taxonomy  => '-ANY-',
  msgid     => '-ANY-',
  includes  => ['include1',     'include2'],
  excludes  => ['exclude1',     'exclude2'],
  begin     => $BEGIN,
  end       => $END,
  pid_param => 'pid_param',
  output    => $OUTPUT,
);
my $cmd = Octopussy::Logs::Extract_Cmd_Line(\%conf_extract);
ok($cmd =~ $RE_CMDLINE, 'Octopussy::Logs::Extract_Cmd_Line()');

# Clean stuff
Octopussy::Device::Remove($DEVICE);
system "rm -rf $DIR_LOGS/$DEVICE/";

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
