=head1 NAME

Octopussy::Taxonomy - Octopussy Taxonomy module

=cut
package Octopussy::Taxonomy;

use strict;
no strict 'refs';

use Octopussy;

use constant FILE_TAXONOMY => "taxonomy";

=head1 FUNCTIONS

=head2 List()

Get list of taxonomy entries

=cut
sub List()
{
	my @list = AAT::XML::File_Array_Values(Octopussy::File(FILE_TAXONOMY), 
		FILE_TAXONOMY, "taxo_id");

	return (undef) if ($#list == -1);
	return (@list);
}

=head2 List_And_Any()

Get list of taxonomy entries and '-ANY-'

=cut
sub List_And_Any()
{
  my @list = ("-ANY-");
  push(@list, List());

	return (undef) if ($#list == -1);
  return (@list);
}

=head2 Colors()

=cut
sub Colors()
{
  my $conf = AAT::XML::Read(Octopussy::File(FILE_TAXONOMY));
  my %color = ();
  foreach my $t (AAT::ARRAY($conf->{taxonomy}))
  	{ $color{"$t->{taxo_id}"} = $t->{color}; }

  return (%color);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
