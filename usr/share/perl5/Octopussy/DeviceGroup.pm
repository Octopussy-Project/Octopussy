# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::DeviceGroup - Octopussy DeviceGroup Module

=cut

package Octopussy::DeviceGroup;

use strict;
use warnings;
use Readonly;

use Octopussy;

Readonly my $FILE_DEVICEGROUPS => 'devicegroups';
Readonly my $XML_ROOT          => 'octopussy_devicegroups';

=head1 FUNCTIONS

=head2 Add($conf_dg)

Add a new Device Group

=cut

sub Add
{
  my $conf_dg = shift;
  my @dgs     = ();

  my $file = Octopussy::File($FILE_DEVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  if ( grep { $_->{dg_id} eq $conf_dg->{dg_id} }
       AAT::ARRAY( $conf->{devicegroup} ) )
  {
    return ('_MSG_DEVICEGROUP_ALREADY_EXISTS');
  }
  push @{ $conf->{devicegroup} }, $conf_dg;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return (undef);
}

=head2 Remove($devicegroup)

Removes devicegroup '$devicegroup'

=cut

sub Remove
{
  my $devicegroup = shift;

  my $file = Octopussy::File($FILE_DEVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @dgs =
    grep { $_->{dg_id} ne $devicegroup } AAT::ARRAY( $conf->{devicegroup} );
  $conf->{devicegroup} = \@dgs;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return (undef);
}

=head2 List()

Get List of Device Group

=cut

sub List
{
  my @dgs = AAT::XML::File_Array_Values( Octopussy::File($FILE_DEVICEGROUPS),
                                         'devicegroup', 'dg_id' );

  return (@dgs);
}

=head2 Configuration($devicegroup)

Get the configuration for the devicegroup '$devicegroup'

=cut

sub Configuration
{
  my $devicegroup = shift;

  my $conf = AAT::XML::Read( Octopussy::File($FILE_DEVICEGROUPS) );
  foreach my $dg ( AAT::ARRAY( $conf->{devicegroup} ) )
  {
    return ($dg) if ( $dg->{dg_id} eq $devicegroup );
  }

  return (undef);
}

=head2 Configurations($sort)

Get the configuration for all devicegroups

=cut

sub Configurations
{
  my $sort = shift || 'dg_id';
  my ( @configurations, @sorted_configurations ) = ( (), () );
  my @dgs = List();
  my %field;

  my @dc = Octopussy::Device::Configurations();
  foreach my $dg (@dgs)
  {
    my $conf = Configuration($dg);
    if ( $conf->{type} eq 'dynamic' )
    {
      @{ $conf->{device} } = ();
      foreach my $d (@dc)
      {
        my $match = 1;
        foreach my $c ( AAT::ARRAY( $conf->{criteria} ) )
        {
          $match = 0 if ( $d->{ $c->{field} } !~ $c->{pattern} );
        }
        push @{ $conf->{device} }, $d->{name} if ($match);
      }
    }
    $field{ $conf->{$sort} } = 1;
    push @configurations, $conf;
  }
  foreach my $f ( sort keys %field )
  {
    push @sorted_configurations, grep { $_->{$sort} eq $f } @configurations;
  }

  return (@sorted_configurations);
}

=head2 Devices($devicegroup)

Get Devices for the devicegroup '$devicegroup'

=cut

sub Devices
{
  my $devicegroup = shift;

  my $conf    = AAT::XML::Read( Octopussy::File($FILE_DEVICEGROUPS) );
  my @devices = ();

  foreach my $dg ( AAT::ARRAY( $conf->{devicegroup} ) )
  {
    if ( $dg->{dg_id} eq $devicegroup )
    {
      if ( $dg->{type} eq 'dynamic' )
      {
        my @dc = Octopussy::Device::Configurations();
        foreach my $d (@dc)
        {
          my $match     = 1;
          my @criterias = AAT::ARRAY( $dg->{criteria} );
          foreach my $c (@criterias)
          {
            $match = 0 if ( $d->{ $c->{field} } !~ $c->{pattern} );
          }
          push @devices, $d->{name} if ($match);
        }
      }
      else { @devices = AAT::ARRAY( $dg->{device} ); }
    }
  }

  return (@devices);
}

=head2 Remove_Device($device)

Removes Device '$device' from all DeviceGroups

=cut

sub Remove_Device
{
  my $device = shift;
  my $file   = Octopussy::File($FILE_DEVICEGROUPS);
  my $conf   = AAT::XML::Read($file);
  my @dgs    = ();
  foreach my $dg ( AAT::ARRAY( $conf->{devicegroup} ) )
  {
    my @devices = ();
    foreach my $d ( AAT::ARRAY( $dg->{device} ) )
    {
      push @devices, $d if ( $d ne $device );
    }
    $dg->{device} = \@devices;
    push @dgs, $dg;
  }
  $conf->{devicegroup} = \@dgs;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return ( scalar @dgs );
}

=head2 Services($devicegroup_name)

Get Services for the DeviceGroup '$devicegroup_name'

=cut

sub Services
{
  my $devicegroup_name = shift;
  my @services = Octopussy::Device::Services( Devices($devicegroup_name) );
  @services =
    sort keys %{ { map { $_ => 1 } @services } };    # sort unique @services

  return (@services);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
