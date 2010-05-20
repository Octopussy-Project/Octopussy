# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Map - Octopussy Map module

=cut

package Octopussy::Map;

use strict;
use warnings;
use Readonly;

use AAT::XML;
use Octopussy::FS;

Readonly my $DIR_MAP => 'maps';

my $dir_maps = undef;

=head1 FUNCTIONS

=head2 List()

Get list of Maps

=cut 

sub List
{
  $dir_maps ||= Octopussy::FS::Directory($DIR_MAP);

  return (AAT::XML::Name_List($dir_maps));
}

=head2 Filename($map)

Get the XML filename for the Map '$map'

=cut 

sub Filename
{
  my $map = shift;

  $dir_maps ||= Octopussy::FS::Directory($DIR_MAP);

  return (AAT::XML::Filename($dir_maps, $map));
}

=head2 Configuration($map)

Get the configuration for the Map '$map'

=cut 

sub Configuration
{
  my $map = shift;

  return (AAT::XML::Read(Filename($map)));
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
