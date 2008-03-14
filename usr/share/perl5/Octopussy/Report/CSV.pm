#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Report::CSV - Octopussy CSV Report module

=cut
package Octopussy::Report::CSV;

use strict;
no strict 'refs';

=head1 FUNCTIONS

=head2 Generate($file, $data, $fields, $headers, $stats)

=cut
sub Generate
{
  my ($file, $data, $fields, $headers, $stats) = @_;
	my @field_list = split(/,/, $fields);
  my $csv = join(";", split(/,/, $headers)) . "\n";

  foreach my $line (@{$data})
  {
    foreach my $f (@field_list)
    {
      if ($f =~ /^(\S+::\S+)\((\S+)\)$/)
      {
        my $result = (Octopussy::Plugin::Function_Source($1) eq "OUTPUT"
					? &{$1}($line->{$2}) : $line->{$2});
        if (ref $result eq "ARRAY")
        {
          foreach my $res (@{$result})
            { $csv .= "$res "; }
        }
        elsif (defined $result)
        {
          $csv .= $result;
        }
      }
      else
        { $csv .= $line->{$f} || "N/A"; }
      $csv .= ";";
    }
    $csv .= "\n";
  }
  open(OUTPUT, "> $file");
  print OUTPUT $csv;
  close(OUTPUT)
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
