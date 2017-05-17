package Octopussy::App::Dispatcher;

=head1 NAME

Octopussy::App::Dispatcher

=head1 DESCRIPTION

Module handling everything for octo_dispatcher program

=head1 SYNOPSIS

octo_dispatcher

=cut

use strict;
use warnings;

our $PROG_NAME = 'octo_dispatcher';

my %dir_device;
my %device_type;

=head2 Handle_Dir($device, $year, $month, $day, $hour, $min)

Handles directory

=cut

sub Handle_Dir
{
    my ($device, $year, $month, $day, $hour, $min) = @_;

    if (!defined $dir_device{$device})
    {
        if (! Octopussy::Device::Valid_Name($device))
        {
            AAT::Syslog::Message($PROG_NAME,
                'LOGS_DROPPED_BECAUSE_INVALID_DEVICE_NAME', $device);
            return (undef);
        }

        my $param_auto_create =
            Octopussy::Parameter('automatic_device_creation');
        my $param_device_regexp =
            Octopussy::Parameter('device_filtering_regexp');
        if (   (defined $param_auto_create)
            && ($param_auto_create =~ /^Disabled$/i))
        {
            AAT::Syslog::Message($PROG_NAME,
                'LOGS_DROPPED_BECAUSE_AUTO_DEVICE_CREATION_DISABLED', $device);
            return (undef);
        }
        elsif ((defined $param_device_regexp)
            && ($device !~ /$param_device_regexp/))
        {
            AAT::Syslog::Message($PROG_NAME,
                'LOGS_DROPPED_BECAUSE_DEVICE_DIDNT_MATCH_REGEXP', $device);
            return (undef);
        }
        else
        {
            if (!-f Octopussy::Device::Filename($device))
            {
                Octopussy::Device::New(
                    {
                        name    => $device,
                        address => $device,
                        description =>
                            "New Device ($year/$month/$day $hour:$min) !"
                    }
                );
                $device_type{$device} = Octopussy::Parameter('devicetype');
                $dir_device{$device} =
                    Octopussy::Storage::Directory_Incoming($device);
            }
        }
    }

    return (undef)  if (!defined $dir_device{$device});

    my $dir_incoming =
        "$dir_device{$device}/$device/Incoming/$year/$month/$day";
    Octopussy::FS::Create_Directory($dir_incoming);

    return ($dir_incoming);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
