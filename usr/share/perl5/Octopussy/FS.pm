# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::FS - Octopussy FileSystem (FS) module

=cut

package Octopussy::FS;

use strict;
use warnings;
use Readonly;

use File::Path;

use AAT::Application;
use Octopussy::Info;

Readonly my $APPLICATION_NAME => 'Octopussy';

=head1 FUNCTIONS

=head2 Chown(@files)

Changes Owner (user & group) for the files '@files'

=cut

sub Chown
{
  my @files = @_;

  my $user = Octopussy::Info::User();
  my $list = '';
  foreach my $f (@files)
  {
    $list .= "\"$f\" ";
  }
  system "chown -R $user:$user $list 2&> /dev/null";

  return (1);
}


=head2 Create_Directory($dir)

Creates Directory '$dir'

=cut

sub Create_Directory
{
  my $dir = shift;

  if (!-d $dir)
  {
    mkpath($dir);
    Chown($dir);
  }

  return ($dir);
}


=head2 Directory($dir)

Returns Octopussy Directory '$dir' Value

=cut

sub Directory
{
  my $dir = shift;

  return (AAT::Application::Directory($APPLICATION_NAME, $dir));
}


=head2 Directories(@dirs)

Returns Octopussy Directories from '@dirs' List

=cut

sub Directories
{
  my @dirs = @_;
  my @list = ();
  foreach my $d (@dirs)
  {
    push @list, AAT::Application::Directory($APPLICATION_NAME, $d);
  }

  return (@list);
}


=head2 File($file)

Returns Octopussy File '$file' Value

=cut

sub File
{
  my $file = shift;

  return (AAT::Application::File($APPLICATION_NAME, $file));
}


=head2 Files(@files)

Returns Octopussy Files from '@files' List

=cut

sub Files
{
  my @files = @_;
  my @list  = ();
  foreach my $f (@files)
  {
    push @list, AAT::Application::File($APPLICATION_NAME, $f);
  }

  return (@list);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut