=head1 NAME

AAT::Object - AAT Object module

=cut
package AAT::Object;

use strict;
use AAT::XML;

=head1 FUNCTIONS

=head2 Configuration($object)

Returns Object configuration

=cut

sub Configuration($)
{
	my $object = shift;

	my $dir = AAT::Directory("objects");
	my $conf = AAT::XML::Read("$dir${object}.xml");

	return ($conf);	
}

=head2 Data($object)

Returns Object data

=cut

sub Data($)
{
	my $object = shift;
	my ($list_conf, $list)  = (undef, undef);

	my $conf = Configuration($object);
	if ($conf->{backend} =~ /^XML$/i)
	{
  	$list_conf = AAT::XML::Read($conf->{source});
  	$object = lc($object);
  	$list = $list_conf->{$object};
	}
	elsif ($conf->{backend} =~ /^DB$/i)
	{
  	my @data = AAT::DB::Query("SELECT * FROM $conf->{source}");
  	$list = \@data;
	}

	return ($list);	
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
