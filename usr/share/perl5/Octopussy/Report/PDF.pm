=head1 NAME

Octopussy::Report::PDF - Octopussy PDF Report module

=cut
package Octopussy::Report::PDF;

use strict;
no strict 'refs';

my $HTMLDOC = "/usr/bin/htmldoc --quiet --webpage --no-compression --no-jpeg";
my $SED = "/bin/sed";
 
=head1 FUNCTIONS

=head2 Generate_From_HTML($file)

Generates PDF Document from an HTML one.

=cut
sub Generate_From_HTML($)
{
  my $file = shift;

	$ENV{HTMLDOC_NOCGI} = 1;
	my $file_pdf = Octopussy::File_Ext($file, "pdf");
	`$SED "s/AAT_THEMES/\\\/usr\\\/share\\\/octopussy\\\/AAT_THEMES/g" "$file" > "$file.tmp"`;
	`$HTMLDOC -f "$file_pdf" "$file.tmp"`;
	Octopussy::Chown($file_pdf);
	unlink("$file.tmp");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
