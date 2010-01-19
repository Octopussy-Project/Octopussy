# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::FS - AAT FileSystem module

=cut

package AAT::FS;

use strict;
use warnings;

=head1 FUNCTIONS

=head2 Directory_Files($dir, $pattern)

Returns Files List from Directory '$dir' that match '$pattern'

=cut

sub Directory_Files
{
  my ($dir, $pattern) = @_;
  my @files = ();

  if (opendir DIR, $dir)
  {
    @files = grep { /$pattern/ } readdir DIR;
    closedir DIR;
  }

  return (sort @files);
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
