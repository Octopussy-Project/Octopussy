=head1 NAME

AAT::List - AAT List module

=cut
package AAT::List;

use strict;
use AAT::XML;

=head1 FUNCTIONS

=head2 Configuration($list)

=cut
sub Configuration($)
{
	my $list = shift;

	my $dir = AAT::Directory("lists");
	my $conf = AAT::XML::Read("$dir${list}.xml");

	return ($conf);	
}

=head2 Items($list)

=cut
sub Items($)
{
	my $list = shift;

	my $dir = AAT::Directory("lists");
	my $conf = AAT::XML::Read("$dir${list}.xml");

	return (AAT::ARRAY($conf->{item}));
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
