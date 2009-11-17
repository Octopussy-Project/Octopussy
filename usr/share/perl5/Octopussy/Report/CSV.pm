# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Report::CSV - Octopussy CSV Report module

=cut

package Octopussy::Report::CSV;

use strict;
no strict 'refs';

=head1 FUNCTIONS

=head2 Generate($file, $array_data, $array_fields, $array_headers)

=cut

sub Generate($$$$)
{
  my ($file, $array_data, $array_fields, $array_headers) = @_;
  my @fields = split(/,/, $array_fields);
  my $csv = join(";", split(/,/, $array_headers)) . "\n";

  foreach my $line (@{$array_data})
  {
    foreach my $f (@fields)
    {
      my $result = Octopussy::Plugin::Field_Data($line, $f);
      if (defined $result)
      {
        if (ref $result eq "ARRAY")
        {
          foreach my $res (@{$result}) { $csv .= "$res "; }
        }
        else { $csv .= $result; }
      }
      else { $csv .= $line->{$f} || "N/A"; }
      $csv .= ";";
    }
    $csv .= "\n";
  }
  open(OUTPUT, "> $file");
  print OUTPUT $csv;
  close(OUTPUT);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
