# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Report::XML - Octopussy XML Report module

=cut

package Octopussy::Report::XML;

use strict;
use warnings;

use AAT;
use AAT::XML;
use Octopussy;
use Octopussy::Plugin;

=head1 FUNCTIONS

=head2 Generate($file, $report, $begin, $end, $devices, $services, $data, 
	$fields, $headers, $stats, $lang)

=cut

sub Generate
{
  my (
       $file, $report, $begin,   $end,   $devices, $services,
       $data, $fields, $headers, $stats, $lang
     ) = @_;
  my @field_list  = split /,/, $fields;
  my @header_list = split /,/, $headers;
  my @headers     = ();
  my $last_header_list = scalar(@header_list) - 1;
  foreach my $i ( 0 .. $last_header_list )
  {
    push @headers, { name => $field_list[$i], value => $header_list[$i] };
  }
  my %conf = (
               name                 => $report,
               begin                => $begin,
               end                  => $end,
               data_nb_files        => $stats->{nb_files},
               data_nb_lines        => $stats->{nb_lines},
               data_generation_time => $stats->{seconds},
               generated_by_version => Octopussy::Version(),
               device               => \@{$devices},
               service              => \@{$services},
               presentation         => { header => \@headers },
             );
  foreach my $line ( @{$data} )
  {
    my %tmp = ();
    foreach my $f (@field_list)
    {
      my $value = '';
      my $result = Octopussy::Plugin::Field_Data( $line, $f );
      if ( defined $result )
      {
        if ( ref $result eq 'ARRAY' )
        {
          foreach my $res ( @{$result} ) { $value .= "$res\n"; }
        }
        elsif ( defined $result ) { $value .= $result; }
      }
      else { $value .= $line->{$f} || 'N/A'; }
      push @{ $tmp{col} }, { name => $f, value => $value };
    }
    push @{ $conf{data}{row} }, \%tmp;
  }
  AAT::XML::Write( $file, \%conf, 'octopussy_report_data' );

  return ($file);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
