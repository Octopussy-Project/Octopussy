#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

AAT::List - AAT List module

=cut
package AAT::List;

use strict;
use AAT::XML;

=head1 FUNCTIONS

=head2 Configuration($list)

Returns List configuration

=cut

sub Configuration($)
{
	my $list = shift;

	my $dir = AAT::Directory("lists");
	my $conf = AAT::XML::Read("$dir${list}.xml");

	return ($conf);	
}

=head2 Items($list)

Returns List items

=cut

sub Items($)
{
	my $list = shift;

	my $conf = Configuration($list);

	return (AAT::ARRAY($conf->{item}));
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
