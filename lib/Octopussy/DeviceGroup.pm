package Octopussy::DeviceGroup;

=head1 NAME

Octopussy::DeviceGroup - Octopussy DeviceGroup Module

=cut

use strict;
use warnings;

use List::MoreUtils qw(any uniq);

use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy::Device;
use Octopussy::FS;

my $FILE_DEVICEGROUPS = Octopussy::FS::File('devicegroups');
my $XML_ROOT          = 'octopussy_devicegroups';

=head1 SUBROUTINES/METHODS

=head2 Add($conf_dg)

Add a new Device Group

=cut

sub Add
{
    my $conf_dg = shift;
    my @dgs     = ();

    my $conf = AAT::XML::Read($FILE_DEVICEGROUPS);
    if (any { $_->{dg_id} eq $conf_dg->{dg_id} } ARRAY($conf->{devicegroup}))
    {
        return ('_MSG_DEVICEGROUP_ALREADY_EXISTS');
    }
    push @{$conf->{devicegroup}}, $conf_dg;
    AAT::XML::Write($FILE_DEVICEGROUPS, $conf, $XML_ROOT);

    return (undef);
}

=head2 Remove($devicegroup)

Removes devicegroup '$devicegroup'

=cut

sub Remove
{
    my $devicegroup = shift;

    my $conf = AAT::XML::Read($FILE_DEVICEGROUPS);
    my @dgs =
        grep { $_->{dg_id} ne $devicegroup } ARRAY($conf->{devicegroup});
    $conf->{devicegroup} = \@dgs;
    AAT::XML::Write($FILE_DEVICEGROUPS, $conf, $XML_ROOT);

    return (undef);
}

=head2 List()

Get List of Device Group

=cut

sub List
{
    my @dgs =
        AAT::XML::File_Array_Values($FILE_DEVICEGROUPS, 'devicegroup', 'dg_id');

    return (@dgs);
}

=head2 Configuration($devicegroup)

Get the configuration for the devicegroup '$devicegroup'

=cut

sub Configuration
{
    my $devicegroup = shift;

    my $conf = AAT::XML::Read($FILE_DEVICEGROUPS);
    foreach my $dg (ARRAY($conf->{devicegroup}))
    {
        return ($dg) if ($dg->{dg_id} eq $devicegroup);
    }

    return (undef);
}

=head2 Configurations($sort)

Get the configuration for all devicegroups

=cut

sub Configurations
{
    my $sort = shift || 'dg_id';
    my (@configurations, @sorted_configurations) = ((), ());
    my @dgs = List();

    my @dc = Octopussy::Device::Configurations();
    foreach my $dg (@dgs)
    {
        my $conf = Configuration($dg);
        if ($conf->{type} eq 'dynamic')
        {
            @{$conf->{device}} = ();
            foreach my $d (@dc)
            {
                my $match = 1;
                foreach my $c (ARRAY($conf->{criteria}))
                {
                    $match = 0
                        if ((defined $d->{$c->{field}})
                        && ($d->{$c->{field}} !~ $c->{pattern}));
                }
                push @{$conf->{device}}, $d->{name} if ($match);
            }
        }
        push @configurations, $conf;
    }
    foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
    {
        push @sorted_configurations, $c;
    }

    return (@sorted_configurations);
}

=head2 Devices($devicegroup)

Get Devices for the devicegroup '$devicegroup'

=cut

sub Devices
{
    my $devicegroup = shift;

    my $conf    = AAT::XML::Read($FILE_DEVICEGROUPS);
    my @dc      = Octopussy::Device::Configurations();
    my @devices = ();

    foreach my $dg (ARRAY($conf->{devicegroup}))
    {
        if ($dg->{dg_id} eq $devicegroup)
        {
            if ($dg->{type} eq 'dynamic')
            {
                foreach my $d (@dc)
                {
                    my $match     = 1;
                    my @criterias = ARRAY($dg->{criteria});
                    foreach my $c (@criterias)
                    {
                        $match = 0
                            if ((defined $d->{$c->{field}})
                            && ($d->{$c->{field}} !~ $c->{pattern}));
                    }
                    push @devices, $d->{name} if ($match);
                }
            }
            else { @devices = ARRAY($dg->{device}); }
        }
    }

    return (@devices);
}

=head2 With_Device($device)

Returns hashref of DeviceGroups matching the Device '$device'

=cut

sub With_Device
{
    my $device = shift;

    my %devicegroup = ();

    my $dc   = Octopussy::Device::Configuration($device);
    my $conf = AAT::XML::Read($FILE_DEVICEGROUPS);
    foreach my $dg (ARRAY($conf->{devicegroup}))
    {
        if ($dg->{type} eq 'dynamic')
        {
            my $match = 1;
            foreach my $c (ARRAY($dg->{criteria}))
            {
                $match = 0
                    if ((!defined $dc->{$c->{field}})
                    || ($dc->{$c->{field}} !~ $c->{pattern}));
            }
            $devicegroup{$dg->{dg_id}} = 1 if ($match);
        }
        else
        {
            foreach my $d (ARRAY($dg->{device}))
            {
                $devicegroup{$dg->{dg_id}} = 1 if ($d eq $device);
            }
        }
    }

    return (%devicegroup);
}

=head2 Remove_Device($device)

Removes Device '$device' from all DeviceGroups

=cut

sub Remove_Device
{
    my $device = shift;
    my $conf   = AAT::XML::Read($FILE_DEVICEGROUPS);
    my @dgs    = ();

    foreach my $dg (ARRAY($conf->{devicegroup}))
    {
        my @devices = ();
        foreach my $d (ARRAY($dg->{device}))
        {
            push @devices, $d if ($d ne $device);
        }
        $dg->{device} = \@devices;
        push @dgs, $dg;
    }
    $conf->{devicegroup} = \@dgs;
    AAT::XML::Write($FILE_DEVICEGROUPS, $conf, $XML_ROOT);

    return (scalar @dgs);
}

=head2 Services($devicegroup_name)

Get Services for the DeviceGroup '$devicegroup_name'

=cut

sub Services
{
    my $devicegroup_name = shift;
    my @services =
        uniq(Octopussy::Device::Services(Devices($devicegroup_name)));

    return (sort @services);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for a DeviceGroup name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1) if ((NOT_NULL($name)) && ($name =~ /^[a-z0-9][a-z0-9_\.-]*$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
