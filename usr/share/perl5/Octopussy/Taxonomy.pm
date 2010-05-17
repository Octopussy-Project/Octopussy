# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Taxonomy - Octopussy Taxonomy module

=cut

package Octopussy::Taxonomy;

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(uniq);

use AAT::Utils qw( ARRAY NOT_NULL);
use AAT::XML;
use Octopussy;
use Octopussy::Device;
use Octopussy::Service;

Readonly my $FILE_TAXONOMY => 'taxonomy';

=head1 FUNCTIONS

=head2 List(\@dev_list, \@serv_list)

Get list of taxonomy entries

=cut

sub List
{
  my ($dev_list, $serv_list) = @_;
  my @list = ();

  if ((NOT_NULL($dev_list)) || (NOT_NULL($serv_list)))
  {
    my %taxo     = ();
    my %color    = Colors();
    my @services = (
      (NOT_NULL($serv_list))
      ? ARRAY($serv_list)
      : Octopussy::Device::Services(ARRAY($dev_list))
    );
    @services = uniq @services;
    foreach my $s (@services)
    {
      if ($s eq '-ANY-')
      {
        @services = Octopussy::Device::Services(ARRAY($dev_list));
      }
    }
    @services = uniq @services;
    foreach my $m (Octopussy::Service::Messages(@services))
    {
      $taxo{$m->{taxonomy}} = 1;
    }
    foreach my $k (keys %taxo)
    {
      push @list, {value => $k, label => $k, color => $color{$k}};
    }
  }
  else
  {
    my %field;
    my $conf = AAT::XML::Read(Octopussy::File($FILE_TAXONOMY));
    foreach my $t (ARRAY($conf->{taxonomy}))
    {
      $field{$t->{value}} = 1;
    }
    foreach my $f (sort keys %field)
    {
      foreach my $t (ARRAY($conf->{taxonomy}))
      {
        $t->{label} = $t->{value};
        if ($t->{value} eq $f)
        {
          push @list, $t;
        }
      }
    }
  }

  return (undef) if (scalar(@list) == 0);
  return (@list);
}

=head2 List_And_Any(\@dev_list, \@serv_list)

Get list of taxonomy entries and '-ANY-'

=cut

sub List_And_Any
{
  my ($dev_list, $serv_list) = @_;

  my @list = ('-ANY-');
  push @list, List($dev_list, $serv_list);

  return (undef) if (scalar(@list) == 0);
  return (@list);
}

=head2 String_List($devices, $services)

=cut

sub String_List
{
  my ($devices, $services) = @_;

  my @d_unknowns = Octopussy::Device::Unknowns(@{$devices});
  my @s_unknowns = Octopussy::Service::Unknowns(@{$services});
  if (scalar @d_unknowns)
  {
    return (sprintf '[ERROR] Unknown Device(s): %s', join ', ', @d_unknowns);
  }
  elsif (scalar @s_unknowns)
  {
    return (sprintf '[ERROR] Unknown Service(s): %s', join ', ', @s_unknowns);
  }
  else
  {
    my @data = Octopussy::Taxonomy::List($devices, $services);
    my @list = ('-ANY-');
    foreach my $d (@data) { push @list, $d->{value}; }

    return ('Taxonomy list: ' . join ', ', sort @list);
  }
}

=head2 Unknowns(@taxos)

Returns list of Unknown Taxonomies in @taxos list

=cut

sub Unknowns
{
  my @taxos    = @_;
  my @unknowns = ();

  my %exist = map { $_->{value} => 1 } List();
  foreach my $t (@taxos)
  {
    push @unknowns, $t if ((!defined $exist{$t}) && ($t ne '-ANY-'));
  }

  return (@unknowns);
}

=head2 Colors()

=cut

sub Colors
{
  my $conf  = AAT::XML::Read(Octopussy::File($FILE_TAXONOMY));
  my %color = ();
  foreach my $t (ARRAY($conf->{taxonomy}))
  {
    $color{"$t->{value}"} = $t->{color};
  }

  return (%color);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
