#!/usr/bin/perl

=head1 NAME

t/Octopussy/Logs.t - Test Suite for Octopussy::Logs module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::Device;
use Octopussy::FS;
use Octopussy::Logs;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $PREFIX    => 'Octo_TEST_';
Readonly my $DEVICE    => "${PREFIX}Device";
Readonly my $SERVICE   => "${PREFIX}Service";
Readonly my $EXTRACTOR => '/usr/sbin/octo_extractor';
Readonly my $DIR_LOGS  => Octopussy::FS::Directory('data_logs');
Readonly my $BEGIN     => '201001010000';
Readonly my $END       => '201001010029';
Readonly my $YEAR      => '2010';
Readonly my $MONTH     => '01';
Readonly my $DAY       => '01';
Readonly my $OUTPUT    => 'output_file.txt';
Readonly my $CMD_DEV_SVC =>
qq(--device "${DEVICE}_1" --device "${DEVICE}_2" --service "${SERVICE}_1" --service "${SERVICE}_2");
Readonly my $CMD_LEVEL_TAXO_ID =>
  qq(--loglevel "-ANY-" --taxonomy "-ANY-" --msgid "-ANY-");
Readonly my $CMD_PERIOD => qq(--begin $BEGIN --end $END);
Readonly my $RE_CMDLINE =>
qr{^$EXTRACTOR $CMD_DEV_SVC $CMD_LEVEL_TAXO_ID $CMD_PERIOD.*--output "$OUTPUT"};


=head2 Generate_Fake_Logs_Files()

=cut

sub Generate_Fake_Logs_Files
{
  system "mkdir -p $DIR_LOGS/$DEVICE/Incoming/$YEAR/01/01/";
  system "mkdir -p $DIR_LOGS/$DEVICE/Unknown/$YEAR/01/01/";
  system "mkdir -p $DIR_LOGS/$DEVICE/$SERVICE/$YEAR/01/01/";
  foreach my $i (0..59)
  {
    my $minute = sprintf '%02d', $i;
    system "touch $DIR_LOGS/$DEVICE/Incoming/2010/01/01/msg_00h${minute}.log";
    my $data = '';
    foreach my $i2 (0..19)
		{ $data .= sprintf "line %02d\n", $i2; }
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

  return (undef);
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

my %start  = (year => $YEAR, month => 1, day => 1, hour => 0, min => 0);
my %finish = (year => $YEAR, month => 1, day => 1, hour => 0, min => 29);
my $start_num = sprintf '%04d%02d%02d%02d%02d',
  $start{year}, $start{month}, $start{day}, $start{hour}, $start{min};
my $finish_num = sprintf '%04d%02d%02d%02d%02d',
  $finish{year}, $finish{month}, $finish{day}, $finish{hour}, $finish{min};

my @files_ymd = Octopussy::Logs::Files_Year_Month_Day(\%start, \%finish,
  "$DIR_LOGS/$DEVICE/$SERVICE", $YEAR);
cmp_ok(scalar @files_ymd, '==', 120, 'Octopussy::Logs::Files_Year_Month_Day()');
my @files_ymdhm =
  Octopussy::Logs::Files_Year_Month_Day_Hour_Min("$DIR_LOGS/$DEVICE/$SERVICE",
  $start_num, $finish_num, \@files_ymd);
cmp_ok(scalar @files_ymdhm, '==', 30,
  'Octopussy::Logs::Files_Year_Month_Day_Hour_Min()');

# Need to create Device/Service
Octopussy::Device::New({name => $DEVICE, address => '1.2.3.4'});
Octopussy::Device::Add_Service($DEVICE, $SERVICE);

my $list_files =
  Octopussy::Logs::Files([$DEVICE], [$SERVICE], \%start, \%finish);
cmp_ok(scalar @{$list_files}, '==', 30, 'Octopussy::Logs::Files()');

my $avail = Octopussy::Logs::Availability($DEVICE, \%start, \%finish);
ok(
  $avail->{$SERVICE}{'01'}{'01'}{'00'}{'00'}
    && $avail->{$SERVICE}{'01'}{'01'}{'00'}{'29'},
  'Octopussy::Logs::Availability()'
);

my ($hash_files, $nb_files) =
  Octopussy::Logs::Minutes_Hash([$DEVICE], [$SERVICE], \%start, \%finish);
ok($nb_files == 30 && defined $hash_files->{'201001010029'},
  'Octopussy::Logs::Minutes_Hash()');

($list_files, $nb_files) =
  Octopussy::Logs::Get_TimePeriod_Files([$DEVICE], [$SERVICE], $BEGIN, $END);
cmp_ok($nb_files, '==', 30, 'Octopussy::Logs::Get_TimePeriod_Files()');

my @files_incoming = Octopussy::Logs::Incoming_Files($DEVICE);
cmp_ok(scalar @files_incoming, '==', 60, 'Octopussy::Logs::Incoming_Files');

my @files_unknown = Octopussy::Logs::Unknown_Files($DEVICE);
cmp_ok(scalar @files_unknown, '==', 60, 'Octopussy::Logs::Unknown_Files');

my $nb_lines_unknown = Octopussy::Logs::Unknown_Number($DEVICE);
cmp_ok($nb_lines_unknown, '==', 120, 'Octopussy::Logs::Unknown_Number');

my $nb_removed = Octopussy::Logs::Remove($DEVICE, 'line 0\d+');
cmp_ok($nb_removed, '==', 600, 'Octopussy::Logs::Remove()');

Octopussy::Logs::Remove_Minute($DEVICE, $YEAR, $MONTH, $DAY, '00', '00');
@files_unknown = Octopussy::Logs::Unknown_Files($DEVICE);
cmp_ok(scalar @files_unknown, '==', 59, 'Octopussy::Logs::Remove_Minute()');

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
  user      => 'Octo_Test',
);
my $cmd = Octopussy::Logs::Extract_Cmd_Line(\%conf_extract);
like($cmd, $RE_CMDLINE, 'Octopussy::Logs::Extract_Cmd_Line()');

# Clean stuff
Octopussy::Device::Remove($DEVICE);
system "rm -rf $DIR_LOGS/$DEVICE/";

done_testing(14);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
