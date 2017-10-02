package Octopussy::App::Parser;

=head1 NAME

Octopussy::App::Parser

=head1 DESCRIPTION

Module with functions for octo_parser program

=cut

use strict;
use warnings;

use Path::Tiny;

use AAT::Syslog;
use Octopussy::App;
use Octopussy::FS;

our $PROG_NAME = 'octo_parser';

=head1 SUBROUTINE/METHODS

=head2 Init()

Init with primary checks

=cut

sub Init
{
	my $device = $ARGV[0];
	
	exit 1	if (!Octopussy::App::Valid_User($PROG_NAME));
	Usage()	if (!defined $device);

	return ($device);
}

=head2 Usage()

Prints octo_parser command usage and exits

=cut

sub Usage
{
	printf "Usage:\n\t$PROG_NAME <device> (run as 'octopussy' user)\n\n";

	exit 1;
}

=head2 Write_Logfile($file, $logs, $compression)

Writes known/recognized Logs '$logs' into Logfile '$file'

=cut

sub Write_Logfile
{
    my ($logfile, $logs, $compression) = @_;

    if (scalar(@{$logs}) > 0)
    {
        $logfile =~ s/(msg_\d\dh\d\d)_\d+/$1/;
        $logfile .= '.gz' if (($logfile !~ /^.+\.gz$/) && $compression);
        Octopussy::FS::Create_Directory(path($logfile)->parent->stringify);
        if ($compression &&
            (defined open my $FILEZIP, '|-', "gzip >> $logfile"))
        {
            foreach my $log (@{$logs}) { print {$FILEZIP} "$log\n"; }
            close $FILEZIP;
        }
        elsif (!$compression)
        {
			path($logfile)->append($logs);
        }
        else
        {
            print "Unable to open file '$logfile'\n";
            AAT::Syslog::Message($PROG_NAME, 'UNABLE_OPEN_FILE', $logfile);
        }
    }

    return (scalar @{$logs});
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
