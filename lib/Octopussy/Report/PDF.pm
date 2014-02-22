=head1 NAME

Octopussy::Report::PDF - Octopussy PDF Report module

=cut

package Octopussy::Report::PDF;

use strict;
use warnings;

use Octopussy;
use Octopussy::FS;

my $HTMLDOC =
  '/usr/bin/htmldoc --quiet --webpage --no-compression --no-jpeg';
my $SED = '/bin/sed';

=head1 FUNCTIONS

=head2 Generate_From_HTML($file)

Generates PDF Document from an HTML one.

=cut

sub Generate_From_HTML
{
  my $file = shift;

  $ENV{HTMLDOC_NOCGI} = 1;
  my $file_pdf = Octopussy::FS::File_Ext( $file, 'pdf' );
`$SED "s/AAT_THEMES/\\\/usr\\\/share\\\/octopussy\\\/AAT_THEMES/g" "$file" > "$file.tmp"`;
  `$HTMLDOC -f "$file_pdf" "$file.tmp"`;
  Octopussy::FS::Chown($file_pdf);
  unlink "$file.tmp";

  return ($file_pdf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
