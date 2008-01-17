=head1 NAME

Octopussy::DeviceGroup - Octopussy DeviceGroup Module

=cut

package Octopussy::DeviceGroup;

use strict;
use Octopussy;

=head1 FUNCTIONS

=head2 Add($dg_conf)

Add a new device group

=cut
 
sub Add($)
{
	my $dg_conf = shift;
	my @dgs = ();

	my $file = Octopussy::File("devicegroups");	
	my $conf = AAT::XML::Read($file);
	foreach my $dg (AAT::ARRAY($conf->{devicegroup}))
  { 
		return ("_MSG_DEVICEGROUP_ALREADY_EXISTS") 
			if ($dg->{dg_id} eq $dg_conf->{dg_id}); 
	}
	push(@{$conf->{devicegroup}}, $dg_conf); 		
	AAT::XML::Write($file, $conf, "octopussy_devicegroups");

	return (undef);
}

=head2 Remove($devicegroup)

Removes devicegroup '$devicegroup'

=cut

sub Remove($)
{
  my $devicegroup = shift;
	my @dgs = ();

	my $file = Octopussy::File("devicegroups");
	my $conf = AAT::XML::Read($file);
	foreach my $dg (AAT::ARRAY($conf->{devicegroup}))
  	{ push(@dgs, $dg)	if ($dg->{dg_id} ne $devicegroup); }
	$conf->{devicegroup} = \@dgs;
	AAT::XML::Write($file, $conf, "octopussy_devicegroups");

	return (undef);
}
 
=head2 List()

Get List of Device Group

=cut

sub List()
{
	my @dgs = AAT::XML::File_Array_Values(Octopussy::File("devicegroups"), 
		"devicegroup", "dg_id");

	return (@dgs);
}

=head2 Configuration($devicegroup)

Get the configuration for the devicegroup '$devicegroup'

=cut

sub Configuration($)
{
  my $devicegroup = shift;

  my $conf = AAT::XML::Read(Octopussy::File("devicegroups"));
	foreach my $dg (AAT::ARRAY($conf->{devicegroup}))
  	{ return ($dg)	if ($dg->{dg_id} eq $devicegroup); }
	
  return (undef);
}

=head2 Configurations($sort)

Get the configuration for all devicegroups

=cut

sub Configurations
{
	my $sort = shift || "dg_id";
	my (@configurations, @sorted_configurations) = ((), ());	
	my @dgs = List();
	my %field;

	my @dc = Octopussy::Device::Configurations();
	foreach my $dg (@dgs)
	{
		my $conf = Configuration($dg);
		if ($conf->{type} eq "dynamic")
		{
			@{$conf->{device}} = ();
    	foreach my $d (@dc)
    	{
				my $match = 1;
				foreach my $c (AAT::ARRAY($conf->{criteria}))
					{ $match = 0	if ($d->{$c->{field}} !~ $c->{pattern}); }
				push(@{$conf->{device}}, $d->{name})	if ($match);
    	}
		}
		$field{$conf->{$sort}} = 1;
		push(@configurations, $conf);
	}
	foreach my $f (sort keys %field)
  {
    foreach my $c (@configurations)
      { push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
  }
	
	return (@sorted_configurations);
}

=head2 Devices($devicegroup)

Get Devices for the devicegroup '$devicegroup'

=cut

sub Devices($)
{
	my $devicegroup = shift;

	my $conf = AAT::XML::Read(Octopussy::File("devicegroups"));
	my @devices = ();

	foreach my $dg (AAT::ARRAY($conf->{devicegroup}))
	{
		if ($dg->{dg_id} eq $devicegroup)
		{
			if ($dg->{type} eq "dynamic")
  		{
    		my @dc = Octopussy::Device::Configurations();
    		foreach my $d (@dc)
    		{
     			my $match = 1;
					my @criterias = AAT::ARRAY($dg->{criteria});	
     			foreach my $c (@criterias)
       			{ $match = 0  if ($d->{$c->{field}} !~ $c->{pattern}); }
     			push(@devices, $d->{name})  if ($match);
    		}
  		}
			else
				{ @devices = AAT::ARRAY($dg->{device}); }
		}
	}

	return (@devices);	
}

=head2 Remove_Device($device)

Removes Device '$device' from all DeviceGroups

=cut

sub Remove_Device($)
{
	my $device = shift;
	my $file = Octopussy::File("devicegroups");
  my $conf = AAT::XML::Read($file);	
	my @dgs = ();
	foreach my $dg (AAT::ARRAY($conf->{devicegroup}))
	{
		my @devices = ();
		foreach my $d (AAT::ARRAY($dg->{device}))
			{ push(@devices, $d)	if ($d ne $device); }
		$dg->{device} = \@devices;
		push(@dgs, $dg);
	}
	$conf->{devicegroup} = \@dgs;
	AAT::XML::Write($file, $conf, "octopussy_devicegroups");
}

=head2 Services($devicegroup_name)

Get Services for the DeviceGroup '$devicegroup_name'

=cut

sub Services($)
{
	my $devicegroup_name = shift;
	my @devices = Devices($devicegroup_name);
	my @services = ();
	my %service;

	foreach my $d (@devices)
	{
		foreach my $s (Octopussy::Device::Services($d))
			{ $service{$s} = 1; }
	}
	foreach my $k (sort keys %service)
		{ push(@services, $k); }

	return (@services);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
