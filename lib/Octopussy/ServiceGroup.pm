=head1 NAME

Octopussy::ServiceGroup - Octopussy ServiceGroup Module

=cut

package Octopussy::ServiceGroup;

use strict;
use warnings;

use List::MoreUtils qw(any);

use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy::FS;

my $FILE_SERVICEGROUPS = 'servicegroups';
my $XML_ROOT           = 'octopussy_servicegroups';

=head1 FUNCTIONS

=head2 Add($conf_sg)

Adds a new ServiceGroup

=cut 

sub Add
{
  my $conf_sg = shift;
  my @sgs     = ();

  my $file = Octopussy::FS::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  if (any { $_->{sg_id} eq $conf_sg->{sg_id} } ARRAY($conf->{servicegroup}))
  {
    return ('_MSG_SERVICEGROUP_ALREADY_EXISTS');
  }
  push @{$conf->{servicegroup}}, $conf_sg;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (undef);
}

=head2 Remove($servicegroup)

Removes ServiceGroup '$servicegroup'

=cut

sub Remove
{
  my $servicegroup = shift;

  my $file = Octopussy::FS::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs =
    grep { $_->{sg_id} ne $servicegroup } ARRAY($conf->{servicegroup});
  $conf->{servicegroup} = \@sgs;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($servicegroup);
}

=head2 List()

Gets list of ServiceGroup

=cut

sub List
{
  my @sgs =
    AAT::XML::File_Array_Values(Octopussy::FS::File($FILE_SERVICEGROUPS),
    'servicegroup', 'sg_id');

  return (@sgs);
}

=head2 Configuration($servicegroup)

Gets the configuration for the ServiceGroup '$servicegroup'

=cut

sub Configuration
{
  my $servicegroup = shift;

  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_SERVICEGROUPS));
  foreach my $sg (ARRAY($conf->{servicegroup}))
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

  foreach my $sg (@sgs)
  {
    my $conf = Configuration($sg);
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Services($servicegroup)

Returns list of Services (sorted by rank) in ServiceGroup '$servicegroup'

=cut

sub Services
{
  my $servicegroup = shift;
  my $conf         = Configuration($servicegroup);
  my @services     = ();

  foreach my $s (sort { $a->{rank} cmp $b->{rank} } ARRAY($conf->{service}))
  {
    push @services, $s;
  }

  return (@services);
}

=head2 Add_Service($servicegroup, $service)

Adds Service '$service' to ServiceGroup '$servicegroup'

=cut

sub Add_Service
{
  my ($servicegroup, $service) = @_;
  my $file = Octopussy::FS::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs  = ();
  foreach my $sg (ARRAY($conf->{servicegroup}))
  {
    my @services = ARRAY($sg->{service});
    if ($sg->{sg_id} eq $servicegroup)
    {
      my $rank = scalar(@services) + 1;
      $rank = sprintf("%02d", $rank);
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
  my $file = Octopussy::FS::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  my @sgs  = ();
  foreach my $sg (ARRAY($conf->{servicegroup}))
  {
    if ($sg->{sg_id} eq $servicegroup)
    {
      my @services = ();
      my $rank     = undef;
      foreach my $s (ARRAY($sg->{service}))
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
          $s->{rank} = sprintf("%02d", $s->{rank});
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
  my $file = Octopussy::FS::File($FILE_SERVICEGROUPS);
  my $conf = AAT::XML::Read($file);
  foreach my $sg (ARRAY($conf->{servicegroup}))
  {
    if ($sg->{sg_id} eq $servicegroup)
    {
      my @services = ();
      my $max = (defined $sg->{service} ? scalar(@{$sg->{service}}) : 0);
      $max = ('0' x (2 - length $max)) . $max;
      foreach my $s (ARRAY($sg->{service}))
      {
        if ($s->{sid} eq $service)
        {
          return ('01') if (($s->{rank} eq '01') && ($direction eq 'up'));
          return ($max)
            if (($s->{rank} eq $max) && ($direction eq 'down'));
          $s->{rank} = ($direction eq 'up' ? $s->{rank} - 1 : $s->{rank} + 1);
          $s->{rank} = sprintf("%02d", $s->{rank});
          $rank = $s->{rank};
        }
        push @services, $s;
      }
      $sg->{service} = \@services;
      my @services2 = ();
      foreach my $s (ARRAY($sg->{service}))
      {
        if (($s->{rank} eq $rank) && ($s->{sid} ne $service))
        {
          $s->{rank} = ($direction eq 'up' ? $s->{rank} + 1 : $s->{rank} - 1);
          $s->{rank} = sprintf("%02d", $s->{rank});
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

=head2 Valid_Name($name)

Checks that '$name' is valid for a ServiceGroup name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1)  if ((NOT_NULL($name)) && ($name =~ /^[a-z][a-z0-9_-]*$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
