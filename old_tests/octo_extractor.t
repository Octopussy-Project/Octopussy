#!/usr/bin/perl

=head1 NAME

octo_extractor.t - Octopussy Source Code Checker for octo_extractor

=cut

use strict;
use warnings;

use FindBin;

use Test::More tests => 6;

use lib "$FindBin::Bin/../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/data/etc/aat/aat.xml");

use Octopussy::FS;

my $BIN = "sudo -u octopussy $FindBin::Bin/../bin/octo_extractor";
my $DIR_LOGS  = Octopussy::FS::Directory('data_logs');
my $PREFIX    = 'Octo_TEST_';
my $DEVICE    = "${PREFIX}Device";
my $SERVICE   = "Octopussy";
my $EXTRACT_DEV_SVC = "$BIN --device $DEVICE --service $SERVICE";
my $PERIOD = '--begin 201001010000 --end 201001010030';

require_ok('Octopussy::Device');

=head2 Generate_Fake_Logs_Files()

=cut

sub Generate_Fake_Logs_Files
{
  system "mkdir -p $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/";
  for (my $i = 0 ; $i <= 59 ; $i++)
  {
    my $minute = sprintf '%02d', $i;
    if (defined open my $FILE,
      '|-',
      "gzip >> $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_00h${minute}.log.gz")
    {
    	my $data = "Jan  1 00:$minute:00 $DEVICE octo_parser: Device: $DEVICE Date: 01/01/2010 00:$minute Time: 2 seconds\n";
    	for (my $i2 = 0 ; $i2 <= 9 ; $i2++) 
    		{ $data .= "Jan  1 00:$minute:00 $DEVICE octo_parser: Device: $DEVICE - Service: Service_$i2 Date: 01/01/2010 00:$minute - Events: 1 / 10\n"; }
      print {$FILE} $data;
      close $FILE;
    }
  }
  #system "chown -R octopussy: $DIR_LOGS/$DEVICE/";
  
  return (undef);
}

# Need to create Device/Service
Octopussy::Device::New({name => $DEVICE, address => '1.2.3.4'});
Octopussy::Device::Add_Service($DEVICE, $SERVICE);

Generate_Fake_Logs_Files();

my $cmd_any = "$EXTRACT_DEV_SVC --loglevel '-ANY-' --taxonomy '-ANY-' --msgid '-ANY-' $PERIOD";
my @lines_any = `$cmd_any`;
ok(scalar @lines_any == (11*31), "octo_extractor --loglevel '-ANY-' --taxonomy '-ANY-' --msgid '-ANY-'");

my $cmd_taxo = "$EXTRACT_DEV_SVC --loglevel '-ANY-' --taxonomy 'Application' --msgid '-ANY-' $PERIOD";
my @lines_taxo = `$cmd_taxo`;
ok(scalar @lines_taxo == (11*31), "octo_extractor --loglevel '-ANY-' --taxonomy 'Application' --msgid '-ANY-'");

my $cmd_loglevel = "$EXTRACT_DEV_SVC --loglevel 'Notice' --taxonomy '-ANY-' --msgid '-ANY-' $PERIOD";
my @lines_loglevel = `$cmd_loglevel`;
ok(scalar @lines_loglevel == 31, "octo_extractor --loglevel 'Notice' --taxonomy '-ANY-' --msgid '-ANY-'");

my $cmd_msgid = "$EXTRACT_DEV_SVC --loglevel '-ANY-' --taxonomy '-ANY-' --msgid 'Octopussy:parser_service_events' $PERIOD";
my @lines_msgid = `$cmd_msgid`;
ok(scalar @lines_msgid == (10*31), "octo_extractor --loglevel '-ANY-' --taxonomy '-ANY-' --msgid 'Octopussy:parser_service_events'");

my $cmd_include = "$EXTRACT_DEV_SVC --loglevel '-ANY-' --taxonomy '-ANY-' --msgid '-ANY-' $PERIOD --include 'Time: \\d+ seconds'";
my @lines_include = `$cmd_include`;
ok(scalar @lines_include == 31, 'octo_extractor (with --include)');

my $cmd_exclude = "$EXTRACT_DEV_SVC --loglevel '-ANY-' --taxonomy '-ANY-' --msgid '-ANY-' $PERIOD --exclude 'Time: \\d+ seconds'";
my @lines_exclude = `$cmd_exclude`;
ok(scalar @lines_exclude == (10*31), 'octo_extractor (with --exclude)');

# Clean stuff
Octopussy::Device::Remove($DEVICE);
system "rm -rf $DIR_LOGS/$DEVICE/";

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
