#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Map - Octopussy Map module

=cut
package Octopussy::Map;

use strict;

use Octopussy;

use constant MAP_DIR	=> "maps";

my $maps_dir = undef;

=head1 FUNCTIONS

=head2 List()

Get list of maps

=cut 
sub List()
{
	$maps_dir ||= Octopussy::Directory(MAP_DIR);

	return (AAT::XML::Name_List($maps_dir));
}

=head2 Filename($map_name)

Get the XML filename for the map '$map_name'

=cut 
sub Filename($)
{
	my $map_name = shift;

	$maps_dir ||= Octopussy::Directory(MAP_DIR);

	return (AAT::XML::Filename($maps_dir, $map_name));
}

=head2 Configuration($map_name)

Get the configuration for the map '$map_name'

=cut 
sub Configuration($)
{
	my $map_name = shift;

	my $conf = AAT::XML::Read(Filename($map_name));

	return ($conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
