# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Cache - Octopussy Cache module

=cut

package Octopussy::Cache;

use strict;
use warnings;
use Readonly;

use Cache::FileCache;

use AAT;

Readonly my $EXPIRES_COMMANDER  => '1 hour';
Readonly my $EXPIRES_DISPATCHER => '2 days';
Readonly my $EXPIRES_EXTRACTOR  => '1 hour';
Readonly my $EXPIRES_PARSER     => '1 day';
Readonly my $EXPIRES_REPORTER   => '1 day';
Readonly my $DIRECTORY_UMASK    => '007';

my (
  $cache_commander, $cache_dispatcher, $cache_extractor,
  $cache_parser,    $cache_reporter
) = (undef, undef, undef, undef, undef);

=head1 FUNCTIONS

=head2 Init($namespace)

Initializes Cache Directory depending on '$namespace'

=cut

sub Init
{
  my $namespace = shift;

  if ($namespace eq 'octo_commander')
  {
    if (AAT::NULL($cache_commander))
    {
      $cache_commander = Set($namespace, $EXPIRES_COMMANDER);
    }
    return ($cache_commander);
  }
  elsif ($namespace eq 'octo_dispatcher')
  {
    if (AAT::NULL($cache_dispatcher))
    {
      $cache_dispatcher = Set($namespace, $EXPIRES_DISPATCHER);
    }
    return ($cache_dispatcher);
  }
  elsif ($namespace eq 'octo_extractor')
  {
    if (AAT::NULL($cache_extractor))
    {
      $cache_extractor = Set($namespace, $EXPIRES_EXTRACTOR);
    }
    return ($cache_extractor);
  }
  elsif ($namespace eq 'octo_parser')
  {
    if (AAT::NULL($cache_parser))
    {
      $cache_parser = Set($namespace, $EXPIRES_PARSER);
    }
    return ($cache_parser);
  }
  elsif ($namespace eq 'octo_reporter')
  {
    if (AAT::NULL($cache_reporter))
    {
      $cache_reporter = Set($namespace, $EXPIRES_REPORTER);
    }
    return ($cache_reporter);
  }

  return (undef);
}

=head2 Set($namespace, $expires)

Sets Cache Directory

=cut

sub Set
{
  my ($namespace, $expires) = @_;

  my $dir = Octopussy::Directory('cache');
  Octopussy::Create_Directory($dir);
  my $cache = new Cache::FileCache(
    {
      namespace          => $namespace,
      cache_root         => $dir,
      default_expires_in => $expires,
      directory_umask    => $DIRECTORY_UMASK
    }
  ) or croak('Couldn\'t instantiate FileCache');

  return ($cache);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
