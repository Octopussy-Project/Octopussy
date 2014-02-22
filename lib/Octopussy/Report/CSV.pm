=head1 NAME

Octopussy::Report::CSV - Octopussy CSV Report module

=cut

package Octopussy::Report::CSV;

use strict;
use warnings;

use Octopussy::Plugin;

=head1 FUNCTIONS

=head2 Generate($file, $array_data, $array_fields, $array_headers)

=cut

sub Generate
{
  my ( $file, $array_data, $array_fields, $array_headers ) = @_;
  my @fields = split /,/, $array_fields;
  my $csv = join( ';', split /,/, $array_headers ) . "\n";

  foreach my $line ( @{$array_data} )
  {
    foreach my $f (@fields)
    {
      my $result = Octopussy::Plugin::Field_Data( $line, $f );
      if ( defined $result )
      {
        if ( ref $result eq 'ARRAY' )
        {
          foreach my $res ( @{$result} ) { $csv .= "$res "; }
        }
        else { $csv .= $result; }
      }
      else { $csv .= $line->{$f} || 'N/A'; }
      $csv .= ';';
    }
    $csv .= "\n";
  }
  if ( defined open my $OUTPUT, '>', $file )
  {
    print {$OUTPUT} $csv;
    close $OUTPUT;

    return ($file);
  }

  return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
