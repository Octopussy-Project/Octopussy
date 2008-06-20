=head1 NAME

Octopussy - Octopussy main module

=cut

package Octopussy;

use strict;
use AAT;
use File::Path;
use Octopussy::Alert;
#use Octopussy::Contact;
use Octopussy::Configuration;
use Octopussy::DB;
use Octopussy::Data_Report;
use Octopussy::Device;
use Octopussy::DeviceGroup;
use Octopussy::Export;
use Octopussy::Graph;
use Octopussy::Location;
use Octopussy::Logs;
use Octopussy::Map;
use Octopussy::Message;
use Octopussy::Plugin;
use Octopussy::Report;
use Octopussy::RRDTool;
use Octopussy::Schedule;
use Octopussy::Search_Template;
use Octopussy::Service;
use Octopussy::ServiceGroup;
use Octopussy::Statistic_Report;
use Octopussy::Stats;
use Octopussy::Storage;
use Octopussy::Table;
use Octopussy::Taxonomy;
use Octopussy::TimePeriod;
use Octopussy::Type;

my $APPLICATION_NAME = "Octopussy";

=head1 FUNCTIONS

=head2 Email()

Returns Octopussy Support Email

=cut
sub Email
{
	my $info = AAT::Application::Info($APPLICATION_NAME);

  return ($info->{email});
}

=head2 User()

Returns Octopussy System User

=cut
sub User
{
	my $info = AAT::Application::Info($APPLICATION_NAME);

  return ($info->{user});
}

=head2 Version()

Returns Octopussy main module Version

=cut
sub Version()
{
	my $info = AAT::Application::Info($APPLICATION_NAME);

	return ($info->{version});
}

=head2 WebSite()

Returns Octopussy WebSite

=cut
sub WebSite()
{
	my $info = AAT::Application::Info($APPLICATION_NAME);

  return ($info->{website});
}

=head2 Directory($dir)

Returns Octopussy Directory '$dir' Value

=cut
sub Directory($)
{
  my $dir = shift;

  return (AAT::Application::Directory($APPLICATION_NAME, $dir));
}

=head2 File($file)

Returns Octopussy File '$file' Value

=cut
sub File($)
{
  my $file = shift;

  return (AAT::Application::File($APPLICATION_NAME, $file));
}

=head2 Parameter($param)

Returns Octopussy Parameter '$param' Default Value

=cut
sub Parameter($)
{
	my $param = shift;

  return (AAT::Application::Parameter($APPLICATION_NAME, $param));
}

=head2 Status_Progress($bin, $param)

Returns Status Progress line for ProgressBar of program $bin

=cut
sub Status_Progress($$)
{
	my ($bin, $param) = @_;
	my $pid_dir = Octopussy::Directory("running");
	my $pid_file = $pid_dir . "${bin}_${param}.pid";
	my $status_file = $pid_dir . "${bin}_${param}.status";
	my $status = "";

	if (-f $pid_file)
	{
  	my $pid = `cat "$pid_file"`;
  	kill USR1 => $pid;
	}
	if (-f $status_file)
	{
  	open(FILE, "cat \"$status_file\" |");
  	$status = <FILE>;
  	close(FILE);
	}

	return ($status);
}

=head2 Sourceforge_Version

Get version of the last release on Sourceforge

=cut
sub Sourceforge_Version
{
	my $SF_SITE = "http://sourceforge.net/project/showfiles.php?group_id=154314";

	my $running_dir = Octopussy::Directory("running");
	my $version = undef;
	AAT::Download("Octopussy", $SF_SITE, "${running_dir}/octopussy.sf_version");
	open(UPDATE, "< ${running_dir}/octopussy.sf_version");
	while (<UPDATE>)
	{
		$version = $1
  		if ($_ =~ /showfiles.php\?group_id=154314&amp;package_id=\d+&amp;release_id=\d+">Octopussy (\S+)<\/a>/);
	}
	close(UPDATE);
	unlink("${running_dir}octopussy.sf_version");
	return ($version);
}

=head2 Web_Updates($type)

Downloads Updates from the Web

=cut
sub Web_Updates
{
	my $type = shift;
	my $file = "_" . lc($type) . ".idx";
	my %update;
	my $website = WebSite();
	my $running_dir = Octopussy::Directory("running");
	AAT::Download("Octopussy", "$website/Download/$type/$file", 
		"$running_dir$file");
	open(UPDATE, "< $running_dir$file");
	while (<UPDATE>)
		{ $update{$1} = $2  if ($_ =~ /^(.+):(\d+)$/); }
	close(UPDATE);
	unlink("$running_dir$file");

	return (\%update);
}

=head2 Chown(@files)

Changes Owner (user & group) for the files '@files'

=cut
sub Chown
{
	my @files = @_;

	my $user = User();
	my $list = "";
	foreach my $f (@files)
	{
		$list .= "\"$f\" ";
	}
	`chown -R $user:$user $list`;
}

=head2 Create_Directory($dir)

Creates Directory '$dir'

=cut
sub Create_Directory
{
	my $dir = shift;

	if (! -d $dir)
	{
		mkpath($dir);
		Chown($dir);
	}
}

=head2 Create_Directory_Inotify($dir)

Creates Directory '$dir' 'directory by directory' 
in order to be watched by inotify

=cut
sub Create_Directory_Inotify
{
  my $dir = shift;
	my $tmp = "";

	my @dirs = split(/\//, $dir);
	foreach my $d (@dirs)
	{
		$tmp .= "/$d";
		if (! -d $tmp)
		{
			mkdir $tmp;
			sleep(1);
		}
	}
}

=head2 File_Ext($file, $extension)

Returns File Extension

=cut
sub File_Ext
{
	my ($file, $extension) = @_;

	$file =~ s/(\.\w+)$/\.$extension/;
	
	return ($file);		
}

=head2 PID_File

Returns PID File

=cut
sub PID_File
{
	my $name = shift;

	my $dir_pid = Octopussy::Directory("running");
	my $pid_file = $dir_pid . $name . ".pid";
	my $user = User();

	my $line = `id $user`;
	my ($uid, $gid) = ($1, $2)
  	if ($line =~ /uid=(\d+)\($user\) gid=(\d+)\($user\)/);
	my @attr = stat($pid_file);

	if ((-f $pid_file) && (($uid != $attr[4]) || ($gid != $attr[5])))
	{
		AAT::Syslog("octopussy", 
			"ERROR: pid file '$pid_file' doesn't match octopussy uid/gid !");
	}
	else
	{
		open(FILE, "> $pid_file");
		print FILE $$;
		close(FILE);
	}

	return ($pid_file);
}

=head2 Device_Stats_File($device)

Returns Device Stats File

=cut
sub Device_Stats_File
{
	my $device = shift;

	my $dir_pid = Octopussy::Directory("running");
	
	return ("$dir_pid/octo_parser" . "_$device.stats");	 
}

=head2 Dialog($id)

Returns Dialog properties for the Dialog '$id'

=cut
sub Dialog
{
	my $id = shift;
	
	my $conf = AAT::XML::Read(Octopussy::File("dialogs"));	
	foreach my $d (AAT::ARRAY($conf->{dialog}))
	{
		return ($d)	if ($d->{d_id} eq $id);
	}

	return (undef);
}

=head2 Dispatcher_Reload()

Reloads Dispatcher

=cut
sub Dispatcher_Reload
{
	my $pid_dir = Octopussy::Directory("running");
  opendir(DIR, $pid_dir);
	my @files = grep /octo_dispatcher\.pid$/, readdir DIR;
  closedir(DIR);

  foreach my $file (@files)
  {
    my $pid = `cat $pid_dir$file`;
    chomp($pid);
		`/bin/kill -HUP $pid`;
  }
}

=head2 Restart

Restarts Octopussy

=cut
sub Restart
{
	`/etc/init.d/octopussy restart`;	
}

=head2 Process_Status()

Returns Status of Processes syslog-ng, dispatcher & scheduler

=cut
sub Process_Status
{
	my %result = ();
	
	my @lines = `ps -edf | grep "syslog-ng" | grep -v grep`;
	$result{"Syslog-ng"} = $#lines+1;
	@lines = `ps -edf | grep "/usr/sbin/octo_dispatcher" | grep -v grep`;
	$result{"Dispatcher"} = $#lines+1;
	@lines = `ps -edf | grep "/usr/sbin/octo_scheduler" | grep -v grep`;
	$result{"Scheduler"} = $#lines+1;

	return (%result);
}

=head2 Timestamp_Version()

Returns timestamp => yyyymmddxxxx

=cut
sub Timestamp_Version
{
  my $conf = shift;
  my ($year, $mon, $mday) = AAT::Datetime::Now();

  my $version = 1;
	if (AAT::NOT_NULL($conf->{version}) 
			&& ($conf->{version} =~ /^$year$mon$mday(\d{4})/))
		{ $version = $1 + 1; }
  $version = AAT::Padding($version, 4);

  return ("$year$mon$mday$version");
}

=head2 Updates_Installation(@updates)

Installs Updates

=cut
sub Updates_Installation
{
  my @updates = @_;
  my $web = Octopussy::WebSite();
  my $main_dir = Octopussy::Directory("main");

  foreach my $u (@updates)
  { 
		AAT::Download("Octopussy", "$web/Download/System/$u.xml", 
			"$main_dir/$u.xml"); 
	}
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
