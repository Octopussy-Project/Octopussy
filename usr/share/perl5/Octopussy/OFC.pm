=head1 NAME

Octopussy::OFC - Octopussy Open Flash Chart (OFC) module
=cut
package Octopussy::OFC;

use strict;

use JSON;

=head1 FUNCTIONS

=head2 Generate(\%conf, $output_file)

=cut
sub Generate
{
  my ($conf, $output_file) = @_;

  my $json = to_json($conf, {utf8 => 1, pretty => 1});
  open(FILE, "> $output_file");
  print FILE $json;
  close(FILE);
  return ($json);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

