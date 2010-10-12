#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

octo_parser.t - Octopussy Source Code Checker for octo_parser

=cut

use strict;
use warnings;
use Readonly;

#use File::Path;
use Test::More tests => 2;

use Octopussy::Device;
use Octopussy::FS;

Readonly my $BIN => '/usr/sbin/octopussy';
Readonly my $DIR_LOGS  => Octopussy::FS::Directory('data_logs');
Readonly my $PREFIX    => 'Octo_TEST_';
Readonly my $DEVICE    => "${PREFIX}Device";
Readonly my $SERVICE   => "Sshd";
Readonly my @LINES => (
	qq{Jun 11 17:10:12 1.2.3.4 sshd[26934]: Invalid user johndoe from 2.3.4.5},
	qq{Jun 11 17:10:14 1.2.3.4 sshd[26934]: Invalid user alansmithee from 2.3.4.5},
	qq{Jun 11 17:10:16 1.2.3.4 unrecognized log},
);

# Need to create Device/Service and some logs
Octopussy::Device::New({name => $DEVICE, address => '1.2.3.4'});
Octopussy::Device::Add_Service($DEVICE, $SERVICE);

Octopussy::FS::Create_Directory("$DIR_LOGS/$DEVICE/Incoming/2010/06/11/");
Octopussy::FS::Chown("$DIR_LOGS/$DEVICE");
if (defined open my $file, '>', "$DIR_LOGS/$DEVICE/Incoming/2010/06/11/msg_17h10_10.log")
{
	foreach my $l (@LINES)
	{
		print $file "$l\n";
	}
	close $file;
}
Octopussy::FS::Chown("$DIR_LOGS/$DEVICE/Incoming/2010/06/11/msg_17h10_10.log");

# Launch octo_parser for 5 seconds
system "$BIN parser-start $DEVICE";
sleep(5);
system "$BIN parser-stop $DEVICE";

my $nb_lines = `zcat $DIR_LOGS/$DEVICE/Sshd/2010/06/11/msg_17h10.log.gz | grep sshd | wc -l`;
chomp $nb_lines;
ok($nb_lines == 2, 'octo_parser wrote Sshd log lines in Sshd directory');
 
$nb_lines = `zcat $DIR_LOGS/$DEVICE/Unknown/2010/06/11/msg_17h10.log.gz | grep unrecognized | wc -l`;
chomp $nb_lines;
ok($nb_lines == 1, 'octo_parser wrote unrecognized log lines in Unknown directory');

# Clean stuff
Octopussy::Device::Remove($DEVICE);
system "rm -rf $DIR_LOGS/$DEVICE/";