#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::ServiceGroup - Octopussy ServiceGroup Module

=cut

package Octopussy::ServiceGroup;

use strict;
no strict 'refs';

use Octopussy;

=head1 FUNCTIONS

=head2 Add($sg_conf)

Add a new service group

=cut 

sub Add($)
{
	my $sg_conf = shift;
	my @sgs = ();

	my $file = Octopussy::File("servicegroups");	
	my $conf = AAT::XML::Read($file);
	foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    return ("_MSG_SERVICEGROUP_ALREADY_EXISTS")
      if ($sg->{sg_id} eq $sg_conf->{sg_id});
  }
	push(@{$conf->{servicegroup}}, $sg_conf); 		
	AAT::XML::Write($file, $conf, "octopussy_servicegroups");
}

=head1 Remove($servicegroup)

Removes servicegroup '$servicegroup'

=cut

sub Remove($)
{
  my $servicegroup = shift;
	my @sgs = ();

	my $file = Octopussy::File("servicegroups");
	my $conf = AAT::XML::Read($file);
	foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  	{ push(@sgs, $sg)	if ($sg->{sg_id} ne $servicegroup); }
	$conf->{servicegroup} = \@sgs;
	AAT::XML::Write($file, $conf, "octopussy_servicegroups");
}

=head2 List()

Get list of service group

=cut

sub List()
{
	my @sgs = AAT::XML::File_Array_Values(Octopussy::File("servicegroups"),
		"servicegroup", "sg_id");

	return (@sgs);
}

=head2 Configuration($servicegroup)

Get the configuration for the servicegroup '$servicegroup'

=cut

sub Configuration($)
{
  my $servicegroup = shift;

  my $conf = AAT::XML::Read(Octopussy::File("servicegroups"));
	foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  	{ return ($sg)	if ($sg->{sg_id} eq $servicegroup); }
	
  return (undef);
}

=head2 Configurations($sort)

Get the configuration for all servicegroups

=cut

sub Configurations
{
	my $sort = shift || "sg_id";
	my (@configurations, @sorted_configurations) = ((), ());	
	my @sgs = List();
	my %field;

	foreach my $sg (@sgs)
	{
		my $conf = Configuration($sg);
		@{$conf->{service}} = ();
		foreach my $s (AAT::ARRAY($conf->{service}))
			{ push(@{$conf->{service}}, $s->{sid}); }
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

=head2 Services($servicegroup)

=cut

sub Services($)
{
	my $servicegroup = shift;

	my $conf = Configuration($servicegroup);
	my @services = ();
  my %field;

  foreach my $s (AAT::ARRAY($conf->{service}))
    { $field{$s->{rank}} = 1; }

  foreach my $f (sort keys %field)
  {
    foreach my $s (AAT::ARRAY($conf->{service}))
      { push(@services, $s) if ($s->{rank} eq $f); }
  }
	return (@services);
}

=head2 Add_Service($servicegroup, $service)

Add a service '$service' to servicegroup '$servicegroup'

=cut

sub Add_Service($$)
{
	my ($servicegroup, $service) = @_;

	my $file = Octopussy::File("servicegroups");
  my $conf = AAT::XML::Read($file);
	my @sgs = ();
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
		my @services = AAT::ARRAY($sg->{service});
    if ($sg->{sg_id} eq $servicegroup)
    {
			my $rank = $#services + 2;
			$rank = AAT::Padding($rank, 2);
			push(@services, { sid => $service, rank => $rank });
		}
		$sg->{service} = \@services;
		push(@sgs, $sg);
	}
	$conf->{servicegroup} = \@sgs;

  AAT::XML::Write(Octopussy::File("servicegroups"), $conf, "octopussy_servicegroups");
}

=head2 Remove_Service($servicegroup, $service)

=cut

sub Remove_Service($$)
{
	my ($servicegroup, $service) = @_;
	my @sgs = ();
  my $file = Octopussy::File("servicegroups");
  my $conf = AAT::XML::Read($file);
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    if ($sg->{sg_id} eq $servicegroup)
    {
			my @services = ();
			my $rank = undef;
      foreach my $s (AAT::ARRAY($sg->{service}))
      {
        if ($s->{sid} ne $service)
        	{ push(@services, $s); }
				else
					{ $rank = $s->{rank}; }
			}
			foreach my $s (@services)
  		{
    		if ($s->{rank} > $rank)
    		{
      		$s->{rank} -= 1;
      		$s->{rank} = AAT::Padding($s->{rank}, 2);
   	 		}
  		}
			$sg->{service} = \@services;
		}
    push(@sgs, $sg);
  }
  $conf->{servicegroup} = \@sgs;
  AAT::XML::Write($file, $conf, "octopussy_servicegroups");
}

=head2 Move_Service($servicegroup, $service, $direction)

=cut

sub Move_Service($$$)
{
	my ($servicegroup, $service, $direction) = @_;
	my $rank = undef;

	my @sgs = ();
	my $file = Octopussy::File("servicegroups");
  my $conf = AAT::XML::Read($file);
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
	{
		if ($sg->{sg_id} eq $servicegroup)
		{
			my @services = ();
  		my $max = (defined $sg->{service} ? $#{$sg->{service}}+1 : 0);
  		$max = ("0"x(2-length($max))) . $max;
  		foreach my $s (AAT::ARRAY($sg->{service}))
  		{
    		if ($s->{sid} eq $service)
   	 		{
      		return () if (($s->{rank} eq "01") && ($direction eq "up"));
      		return () if (($s->{rank} eq "$max") && ($direction eq "down"));
      		$s->{rank} = ($direction eq "up" ? $s->{rank} - 1 : $s->{rank} + 1);
      		$s->{rank} = AAT::Padding($s->{rank}, 2);
      		$rank = $s->{rank};
    		}
    		push(@services, $s);
  		}
  		$sg->{service} = \@services;
  		my @services2 = ();
  		foreach my $s (AAT::ARRAY($sg->{service}))
  		{
    		if (($s->{rank} eq $rank) && ($s->{sid} ne $service))
    		{
      		$s->{rank} = ($direction eq "up" ? $s->{rank} + 1 : $s->{rank} - 1);
      		$s->{rank} = AAT::Padding($s->{rank}, 2);
    		}
    		push(@services2, $s);
  		}
  		$sg->{service} = \@services2;
		}
		push(@sgs, $sg);
	}
	$conf->{servicegroup} = \@sgs;
	
  AAT::XML::Write($file, $conf, "octopussy_servicegroups");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
