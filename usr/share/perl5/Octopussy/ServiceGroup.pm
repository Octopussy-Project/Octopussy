# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::ServiceGroup - Octopussy ServiceGroup Module

=cut

package Octopussy::ServiceGroup;

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any);

use AAT;
use AAT::XML;
use Octopussy;

Readonly my $FILE_SERVICEGROUPS => 'servicegroups';
Readonly my $XML_ROOT           => 'octopussy_servicegroups';

=head1 FUNCTIONS

=head2 Add($conf_sg)

Adds a new ServiceGroup

=cut 

sub Add
{
  my $conf_sg = shift;
  my @sgs     = ();

  my $file = Octopussy::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  if (any { $_->{sg_id} eq $conf_sg->{sg_id} }
    AAT::ARRAY($conf->{servicegroup}))
  {
    return ('_MSG_SERVICEGROUP_ALREADY_EXISTS');
  }
  push @{$conf->{servicegroup}}, $conf_sg;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (undef);
}

=head1 Remove($servicegroup)

Removes ServiceGroup '$servicegroup'

=cut

sub Remove
{
  my $servicegroup = shift;

  my $file = Octopussy::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs =
    grep { $_->{sg_id} ne $servicegroup } AAT::ARRAY($conf->{servicegroup});
  $conf->{servicegroup} = \@sgs;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($servicegroup);
}

=head2 List()

Gets list of ServiceGroup

=cut

sub List
{
  my @sgs = AAT::XML::File_Array_Values(Octopussy::File($FILE_SERVICEGROUPS),
    'servicegroup', 'sg_id');

  return (@sgs);
}

=head2 Configuration($servicegroup)

Gets the configuration for the ServiceGroup '$servicegroup'

=cut

sub Configuration
{
  my $servicegroup = shift;

  my $conf = AAT::XML::Read(Octopussy::File($FILE_SERVICEGROUPS));
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    return ($sg) if ($sg->{sg_id} eq $servicegroup);
  }

  return (undef);
}

=head2 Configurations($sort)

Gets the configuration for all ServiceGroups

=cut

sub Configurations
{
  my $sort = shift || 'sg_id';
  my (@configurations, @sorted_configurations) = ((), ());
  my @sgs = List();
  my %field;

  foreach my $sg (@sgs)
  {
    my $conf = Configuration($sg);
    $field{$conf->{$sort}} = 1;
    push @configurations, $conf;
  }
  foreach my $f (sort keys %field)
  {
    push @sorted_configurations, grep { $_->{$sort} eq $f } @configurations;
  }

  return (@sorted_configurations);
}

=head2 Services($servicegroup)

Returns list of Services in ServiceGroup '$servicegroup'

=cut

sub Services
{
  my $servicegroup = shift;

  my $conf     = Configuration($servicegroup);
  my @services = ();
  my %field;

  foreach my $s (AAT::ARRAY($conf->{service})) { $field{$s->{rank}} = 1; }

  foreach my $f (sort keys %field)
  {
    push @services, grep { $_->{rank} eq $f } AAT::ARRAY($conf->{service});
  }
  return (@services);
}

=head2 Add_Service($servicegroup, $service)

Adds Service '$service' to ServiceGroup '$servicegroup'

=cut

sub Add_Service
{
  my ($servicegroup, $service) = @_;
  my $file = Octopussy::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs  = ();
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    my @services = AAT::ARRAY($sg->{service});
    if ($sg->{sg_id} eq $servicegroup)
    {
      my $rank = scalar(@services) + 1;
      $rank = AAT::Padding($rank, 2);
      if (any { $_->{sid} =~ /^$service$/ } @services)
      {
        return ();
      }
      push @services, {sid => $service, rank => $rank};
    }
    $sg->{service} = \@services;
    push @sgs, $sg;
  }
  $conf->{servicegroup} = \@sgs;

  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($service);
}

=head2 Remove_Service($servicegroup, $service)

Removes Service '$service' from ServiceGroup '$servicegroup'

=cut

sub Remove_Service
{
  my ($servicegroup, $service) = @_;
  my $file = Octopussy::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs  = ();
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    if ($sg->{sg_id} eq $servicegroup)
    {
      my @services = ();
      my $rank     = undef;
      foreach my $s (AAT::ARRAY($sg->{service}))
      {
        if ($s->{sid} ne $service) { push @services, $s; }
        else                       { $rank = $s->{rank}; }
      }
      return () if (!defined $rank);
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
    push @sgs, $sg;
  }
  $conf->{servicegroup} = \@sgs;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (scalar @sgs);
}

=head2 Move_Service($servicegroup, $service, $direction)

Moves Service '$service' in ServiceGroup '$servicegroup' Services List
in Direction Up or Down ('$direction')

=cut

sub Move_Service
{
  my ($servicegroup, $service, $direction) = @_;
  my $rank = undef;

  my @sgs  = ();
  my $file = Octopussy::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  foreach my $sg (AAT::ARRAY($conf->{servicegroup}))
  {
    if ($sg->{sg_id} eq $servicegroup)
    {
      my @services = ();
      my $max = (defined $sg->{service} ? scalar(@{$sg->{service}}) : 0);
      $max = ('0' x (2 - length $max)) . $max;
      foreach my $s (AAT::ARRAY($sg->{service}))
      {
        if ($s->{sid} eq $service)
        {
          return ('01') if (($s->{rank} eq '01') && ($direction eq 'up'));
          return ($max)
            if (($s->{rank} eq $max) && ($direction eq 'down'));
          $s->{rank} = ($direction eq 'up' ? $s->{rank} - 1 : $s->{rank} + 1);
          $s->{rank} = AAT::Padding($s->{rank}, 2);
          $rank = $s->{rank};
        }
        push @services, $s;
      }
      $sg->{service} = \@services;
      my @services2 = ();
      foreach my $s (AAT::ARRAY($sg->{service}))
      {
        if (($s->{rank} eq $rank) && ($s->{sid} ne $service))
        {
          $s->{rank} = ($direction eq 'up' ? $s->{rank} + 1 : $s->{rank} - 1);
          $s->{rank} = AAT::Padding($s->{rank}, 2);
        }
        push @services2, $s;
      }
      $sg->{service} = \@services2;
    }
    push @sgs, $sg;
  }
  $conf->{servicegroup} = \@sgs;

  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($rank);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
