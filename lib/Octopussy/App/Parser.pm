package Octopussy::App::Parser;

=head1 NAME

Octopussy::App::Parser

=head1 DESCRIPTION

Module with functions for octo_parser program

=cut

use strict;
use warnings;

use File::Basename;
use File::Slurp;

use Octopussy::App;

our $PROG_NAME = 'octo_parser';

exit if (!Octopussy::App::Valid_User($PROG_NAME));

=head1 SUBROUTINE/METHODS

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
        Octopussy::FS::Create_Directory(dirname($logfile));
        if ($compression &&
            (defined open my $FILEZIP, '|-', "gzip >> $logfile"))
        {
            foreach my $log (@{$logs}) { print {$FILEZIP} "$log\n"; }
            close $FILEZIP;
        }
        elsif (!$compression)
        {
			write_file($logfile, { append => 1 }, @{$logs});
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
