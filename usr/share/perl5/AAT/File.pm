=head1 NAME

AAT::File - AAT File module

=cut

package AAT::File;

use strict;

my $MIME_SMALL_DIR = "THEMES/DEFAULT/mime/22x22";
my $MIME_BIG_DIR = "THEMES/DEFAULT/mime/128x128";

=head1 FUNCTIONS

=head2 Mime_Icon($file, $type)

=cut

sub Mime_Icon($$)
{
	my ($file, $type) = @_;

	my $dir = (((AAT::NOT_NULL($type)) && ($type =~ /BIG/i)) 
		? $MIME_BIG_DIR : $MIME_SMALL_DIR);
	my $ext = $1  if ($file =~ /.+\.(\w+)$/);
	return ("$dir/$ext.png")	if ((defined $ext) && (-f "$dir/$ext.png"));
	return ("$dir/DIRECTORY.png")	if (-d $file);
	return ("$dir/FILE.png");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
