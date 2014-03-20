#!/usr/bin/perl

=head1 NAME

t/Octopussy/Logs.t - Test Suite for Octopussy::Logs module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

my $AAT_CONFIG_FILE_TEST = "$FindBin::Bin/../data/etc/aat/aat.xml";
AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

use Octopussy::FS;

my $PREFIX    = 'Octo_TEST_';
my $DEVICE    = "${PREFIX}Device";
my $SERVICE   = "${PREFIX}Service";
my $EXTRACTOR = '/usr/sbin/octo_extractor';
my $DIR_LOGS  = Octopussy::FS::Directory('data_logs');
my $BEGIN     = '201001010000';
my $END       = '201001010029';
my $YEAR      = '2010';
my $MONTH     = '01';
my $DAY       = '01';
my $OUTPUT    = 'output_file.txt';
my $CMD_DEV_SVC =
qq(--device "${DEVICE}_1" --device "${DEVICE}_2" --service "${SERVICE}_1" --service "${SERVICE}_2");
my $CMD_LEVEL_TAXO_ID =
  qq(--loglevel "-ANY-" --taxonomy "-ANY-" --msgid "-ANY-");
my $CMD_PERIOD = qq(--begin $BEGIN --end $END);
my $RE_CMDLINE =
qr{^$EXTRACTOR $CMD_DEV_SVC $CMD_LEVEL_TAXO_ID $CMD_PERIOD.*--output "$OUTPUT"};

require_ok('Octopussy::Device');
require_ok('Octopussy::Logs');

=head2 Generate_Fake_Logs_Files()

=cut

sub Generate_Fake_Logs_Files
{
  mkpath("$DIR_LOGS/$DEVICE/Incoming/$YEAR/01/01/");
  mkpath("$DIR_LOGS/$DEVICE/Unknown/$YEAR/01/01/");
  mkpath("$DIR_LOGS/$DEVICE/$SERVICE/$YEAR/01/01/");
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
rmtree("$DIR_LOGS/$DEVICE/");

done_testing(2 + 14);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
