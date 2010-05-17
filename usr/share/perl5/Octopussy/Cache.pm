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

use Octopussy;

Readonly my $EXPIRES_COMMANDER  => '1 hour';
Readonly my $EXPIRES_DISPATCHER => '2 days';
Readonly my $EXPIRES_EXTRACTOR  => '1 hour';
Readonly my $EXPIRES_PARSER     => '1 day';
Readonly my $EXPIRES_REPORTER   => '1 day';
Readonly my $DIRECTORY_UMASK    => '007';

my %cache = (
  'octo_commander'    => {cache => undef, expires => $EXPIRES_COMMANDER},
  'octo_dispatcher'   => {cache => undef, expires => $EXPIRES_DISPATCHER},
  'octo_extractor'    => {cache => undef, expires => $EXPIRES_EXTRACTOR},
  'octo_parser'       => {cache => undef, expires => $EXPIRES_PARSER},
  'octo_reporter'     => {cache => undef, expires => $EXPIRES_REPORTER},
  'octo_syslog_cache' => {cache => undef, expires => $EXPIRES_DISPATCHER},
);

=head1 FUNCTIONS

=head2 Init($namespace)

Initializes Cache Directory depending on '$namespace'

=cut

sub Init
{
  my $namespace = shift;

  if (defined $cache{$namespace})
  {
    if (!defined $cache{$namespace}{cache})
    {
      $cache{$namespace}{cache} = Set($namespace, $cache{$namespace}{expires});
    }
    return ($cache{$namespace}{cache});
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
