# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Search_Template - Octopussy Search Template module

=cut

package Octopussy::Search_Template;

use strict;
use warnings;
use Readonly;
use bytes;
use utf8;
use Octopussy;

Readonly my $DIR_SEARCH_TPL => 'search_templates';
Readonly my $XML_ROOT       => 'octopussy_search_template';

my $dir_search_tpl = undef;
my %filename;

=head1 FUNCTIONS

=head2 New($user, \%conf)

Create a new Search Template
 
Parameters:

$user - user who create this template
\%conf - hashref of the new Search Template configuration

=cut

sub New
{
  my ($user, $conf) = @_;

  $dir_search_tpl ||= Octopussy::Directory($DIR_SEARCH_TPL);
  Octopussy::Create_Directory("$dir_search_tpl/$user");
  AAT::XML::Write("$dir_search_tpl/$user/$conf->{name}.xml", $conf, $XML_ROOT);

  return ($conf->{name});
}

=head2 Remove($user, $search_tpl)

Remove the Search Template '$search_tpl'
 
Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template to remove

=cut

sub Remove
{
  my ($user, $search_tpl) = @_;

  my $nb = unlink Filename($user, $search_tpl);
  $filename{$user}{$search_tpl} = undef;

  return ($nb);
}

=head2 List($user)

Get list of Search Templates
 
Parameters:

$user - user who created this template

Returns:

@tpls - Array of Search Templates names

=cut

sub List
{
  my $user = shift;

  $dir_search_tpl ||= Octopussy::Directory($DIR_SEARCH_TPL);
  my @files = AAT::FS::Directory_Files("$dir_search_tpl/$user/", qr/.+\.xml$/);
  my @tpls = ();
  foreach my $f (@files)
  {
    my $conf = AAT::XML::Read("$dir_search_tpl/$user/$f");
    push @tpls, $conf->{name} if (defined $conf->{name});
  }

  return (sort @tpls);
}

=head2 List_Any_User($sort)

Get template name / user List

Parameters:

$sort - selected field to sort List

Returns:

@sorted_list - Array of Search Templates names for all users

=cut

sub List_Any_User
{
  my $sort = shift;

  my (@list, @sorted_list) = ();
  my %field;

  $dir_search_tpl ||= Octopussy::Directory($DIR_SEARCH_TPL);
  my @dirs = AAT::FS::Directory_Files("$dir_search_tpl/", qr/\w+$/);
  foreach my $d (@dirs)
  {
    my @files = AAT::FS::Directory_Files("$dir_search_tpl/$d/", qr/.+\.xml$/);
    foreach my $f (@files)
    {
      my $conf = AAT::XML::Read("$dir_search_tpl/$d/$f");
      my $key = (defined $conf->{$sort} ? $conf->{$sort} : $d);
      $field{$key} = 1;
      push @list, {name => $conf->{name}, user => $d}
        if (defined $conf->{name});
    }
  }
  foreach my $f (sort keys %field)
  {
    push @sorted_list, grep { $_->{$sort} eq $f } @list;
  }

  return (@sorted_list);
}

=head2 Filename($user, $search_tpl)

Get the XML filename for the Search Template '$search_tpl'

Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template

Returns:

$filename - Filename of the XML file for Search Template '$search_tpl'

=cut

sub Filename
{
  my ($user, $search_tpl) = @_;

  return ($filename{$user}{$search_tpl})
    if (defined $filename{$user}{$search_tpl});
  if (AAT::NOT_NULL($search_tpl))
  {
    $dir_search_tpl ||= Octopussy::Directory($DIR_SEARCH_TPL);
    my @files =
      AAT::FS::Directory_Files("$dir_search_tpl/$user/", qr/.+\.xml$/);
    foreach my $f (@files)
    {
      my $conf = AAT::XML::Read("$dir_search_tpl/$user/$f");
      if ((defined $conf) && ($conf->{name} =~ /^$search_tpl$/))
      {
        $filename{$user}{$search_tpl} = "$dir_search_tpl/$user/$f";
        return ("$dir_search_tpl/$user/$f");
      }
    }
  }

  return (undef);
}

=head2 Configuration($user, $search_tpl)

Get the configuration for the Search Template '$search_tpl'
 
Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template

Returns:

\%conf - Hashref of the Search Template configuration

=cut

sub Configuration
{
  my ($user, $search_tpl) = @_;

  return (AAT::XML::Read(Filename($user, $search_tpl)));
}

=head2 Configurations($user, $sort)

Get the configuration for all Search Templates from User $user

Parameters:

$user - user who created this template
$sort - selected field to sort configurations

Returns:

@configurations - Array of Hashref Search Template configurations  

=cut

sub Configurations
{
  my ($user, $sort) = @_;
  my (@configurations, @sorted_configurations) = ((), ());
  my @tpls = List($user);
  my %field;

  foreach my $t (@tpls)
  {
    my $conf = Configuration($user, $t);
    if (defined $conf->{name})
    {
      $field{$conf->{$sort}} = 1;
      push @configurations, $conf;
    }
  }
  foreach my $f (sort keys %field)
  {
    push @sorted_configurations, grep { $_->{$sort} eq $f } @configurations;
  }

  return (@sorted_configurations);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
