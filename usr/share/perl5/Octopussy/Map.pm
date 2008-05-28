=head1 NAME

Octopussy::Map - Octopussy Map module

=cut

package Octopussy::Map;

use strict;
use Octopussy;

my $MAP_DIR	= "maps";
my $maps_dir = undef;

=head1 FUNCTIONS

=head2 List()

Get list of Maps

=cut 
sub List()
{
	$maps_dir ||= Octopussy::Directory($MAP_DIR);

	return (AAT::XML::Name_List($maps_dir));
}

=head2 Filename($map)

Get the XML filename for the Map '$map'

=cut 
sub Filename($)
{
	my $map = shift;

	$maps_dir ||= Octopussy::Directory($MAP_DIR);

	return (AAT::XML::Filename($maps_dir, $map));
}

=head2 Configuration($map)

Get the configuration for the Map '$map'

=cut 
sub Configuration($)
{
	my $map = shift;

	my $conf = AAT::XML::Read(Filename($map));

	return ($conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
