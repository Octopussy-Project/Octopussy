=head1 NAME

Octopussy::System - Octopussy System module

=cut

package Octopussy::System;

use strict;
use warnings;

use App::Info::HTTPD::Apache;

=head1 FUNCTIONS

=head2 Apache2_Binary()

Returns Apache2 Binary

=cut

sub Apache2_Binary
{	
	my $apache = App::Info::HTTPD::Apache->new();
  	return ($apache->executable)	if (defined $apache->executable);
      
  	return (undef);
}


=head2 Dispatcher_Reload()

Reloads Dispatcher

=cut

sub Dispatcher_Reload
{
  	my $dir_pid = Octopussy::FS::Directory('running');
  
	if (defined opendir DIR, $dir_pid)
	{
  		my @files = grep { /octo_dispatcher\.pid$/ } readdir DIR;
  		closedir DIR;

  		foreach my $file (@files)
  		{
    		my $pid = `cat $dir_pid$file`;
    		chomp $pid;
    		kill HUP => $pid;
  		}

  	return (1);
	}

	return (undef);
}


=head2 Restart()

Restarts Octopussy

=cut

sub Restart
{
  `/etc/init.d/octopussy restart`;

  return (1);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
