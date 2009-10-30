# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy - Octopussy main module

=cut

package Octopussy;

use strict;
use warnings;
use version;
use Readonly;

use File::Basename;
use File::Path;
use Proc::PID::File;
use POSIX qw(mkfifo);

use AAT;
use Octopussy::Alert;
use Octopussy::Cache;

use Octopussy::Configuration;
use Octopussy::DB;
use Octopussy::Data_Report;
use Octopussy::Device;
use Octopussy::DeviceGroup;
use Octopussy::Export;
use Octopussy::Location;
use Octopussy::Loglevel;
use Octopussy::Logs;
use Octopussy::Map;
use Octopussy::Message;
use Octopussy::OFC;
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
use Octopussy::World_Stats;

Readonly my $APPLICATION_NAME => 'Octopussy';
Readonly my $SF_SITE => 'http://sf.net/project/showfiles.php?group_id=154314';

$Octopussy::VERSION = qv('0.9.9.7');

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

=head2 Valid_User($prog_name)

Checks that current user is Octopussy user for program $prog_name

=cut

sub Valid_User
{
  my $prog_name = shift;

  my @info      = getpwuid($<);
  my $octo_user = User();

  return (1) if ($info[0] =~ /^$octo_user$/);

  AAT::Syslog($prog_name, "You have to be Octopussy user to use $prog_name");
  printf("You have to be Octopussy user to use %s !\n", $prog_name);

  return (0);
}

=head2 Version()

Returns Octopussy main module Version

=cut

sub Version
{
  return ($Octopussy::VERSION);
}

=head2 WebSite()

Returns Octopussy WebSite

=cut

sub WebSite
{
  my $info = AAT::Application::Info($APPLICATION_NAME);

  return ($info->{website});
}

=head2 Commander($cmd)

Add command $cmd to octo_commander commands list

=cut

sub Commander
{
  my $cmd = shift;

  my $cache = Octopussy::Cache::Init("octo_commander");
  if (defined $cache)
  {
    my $commands = $cache->get("commands") || ();
    push(@{$commands}, $cmd);
    $cache->set("commands", $commands);

    return ($cmd);
  }

  return (undef);
}

=head2 Die($prog_name, $msg)

Syslog error $msg before dying

=cut

sub Die
{
  my ($prog_name, $msg) = @_;

  AAT::Syslog($prog_name, $msg);
  die $msg;
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
    push(@list, AAT::Application::Directory($APPLICATION_NAME, $d));
  }

  return (@list);
}

=head2 Error

Syslogs error and prints it

=cut

sub Error
{
  my ($module, $msg, @args) = @_;

  my $message = AAT::Syslog($module, $msg, @args);
  print "$module: $message\n";

  return ("$module: $message\n");
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
    push(@list, AAT::Application::File($APPLICATION_NAME, $f));
  }

  return (@list);
}

=head2 Parameter($param)

Returns Octopussy Parameter '$param' Default Value

=cut

sub Parameter
{
  my $param = shift;

  return (AAT::Application::Parameter($APPLICATION_NAME, $param));
}

=head2 Status_Progress($bin, $param)

Returns Status Progress line for ProgressBar of program $bin

=cut

sub Status_Progress
{
  my ($bin, $param) = @_;
  my $dir_pid  = Octopussy::Directory('running');
  my $file_pid = "${dir_pid}${bin}_${param}.pid";
  my $status   = "";

  if (defined open(my $FILEPID, '<', $file_pid))
  {
    my $pid = <$FILEPID>;
    chomp($pid);
    my $cache = Octopussy::Cache::Init($bin);
    $status = $cache->get("status_${pid}");
    close($FILEPID);
  }

  return ($status);
}

=head2 Sourceforge_Version()

Get version of the last release on Sourceforge

=cut

sub Sourceforge_Version
{
  my $dir_running = Octopussy::Directory('running');
  my $version     = undef;
  AAT::Download($APPLICATION_NAME, $SF_SITE,
    "${dir_running}/octopussy.sf_version");
  if (defined open(my $UPDATE, '<', "${dir_running}/octopussy.sf_version"))
  {
    while (<$UPDATE>)
    {
      $version = $1
        if ($_ =~
/showfiles.php\?group_id=154314&amp;package_id=\d+&amp;release_id=\d+">Octopussy (\S+)<\/a>/
        );
    }
    close($UPDATE);
    unlink("${dir_running}octopussy.sf_version");
  }

  return ($version);
}

=head2 Web_Updates($type)

Downloads Updates from the Web

=cut

sub Web_Updates
{
  my $type = shift;
  my $file = '_' . lc($type) . '.idx';
  my %update;
  my $website     = WebSite();
  my $dir_running = Octopussy::Directory('running');
  AAT::Download('Octopussy', "$website/Download/$type/$file",
    "$dir_running$file");
  if (defined open(my $UPDATE, '<', "$dir_running$file"))
  {
    while (<$UPDATE>) { $update{$1} = $2 if ($_ =~ /^(.+):(\d+)$/); }
    close($UPDATE);
    unlink("$dir_running$file");
  }

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

=head2 Create_Fifo($fifo)

Creates Fifo '$fifo'

=cut

sub Create_Fifo
{
  my $fifo = shift;

  if (!-p $fifo)
  {
    my ($file, $dir, $suffix) = fileparse($fifo);
    Create_Directory($dir);
    mkfifo($fifo, '0700');
    Chown($fifo);
  }

  return ($fifo);
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

  my $dir_pid  = Octopussy::Directory('running');
  my $file_pid = $dir_pid . $name . '.pid';
  my $user     = User();

  my $line = `id $user`;
  if ($line =~ /uid=(\d+)\($user\) gid=(\d+)\($user\)/)
  {
    my ($uid, $gid) = ($1, $2);
    my @attr = stat($file_pid);

    if ((-f $file_pid) && (($uid != $attr[4]) || ($gid != $attr[5])))
    {
      AAT::Syslog('octopussy',
        "ERROR: pid file '$file_pid' doesn't match octopussy uid/gid !");
    }
    else
    {
      return (undef)
        if (Proc::PID::File->running(dir => $dir_pid, name => $name));
    }
  }

  return ($file_pid);
}

=head2 Dialog($id)

Returns Dialog properties for the Dialog '$id'

=cut

sub Dialog
{
  my $id = shift;

  my $conf = AAT::XML::Read(Octopussy::File('dialogs'));
  foreach my $d (AAT::ARRAY($conf->{dialog}))
  {
    return ($d) if ($d->{d_id} eq $id);
  }

  return (undef);
}

=head2 Dispatcher_Reload()

Reloads Dispatcher

=cut

sub Dispatcher_Reload
{
  my $dir_pid = Octopussy::Directory('running');
  opendir(DIR, $dir_pid);
  my @files = grep { /octo_dispatcher\.pid$/ } readdir DIR;
  closedir(DIR);

  foreach my $file (@files)
  {
    my $pid = `cat $dir_pid$file`;
    chomp($pid);
    `/bin/kill -HUP $pid`;
  }

  return (1);
}

=head2 Restart()

Restarts Octopussy

=cut

sub Restart
{
  `/etc/init.d/octopussy restart`;

  return (1);
}

=head2 Process_Status()

Returns Status of Processes syslog-ng, dispatcher & scheduler

=cut

sub Process_Status
{
  my %result = ();

  #my @lines = `ps -edf | grep "syslog-ng" | grep -v grep`;
  my @lines = `ps -edf | grep "rsyslog" | grep -v grep`;

  #$result{"Syslog-ng"} = scalar(@lines);
  $result{'Rsyslog'} = scalar(@lines);
  @lines = `ps -edf | grep "/usr/sbin/octo_dispatcher" | grep -v grep`;
  $result{'Dispatcher'} = scalar(@lines);
  @lines = `ps -edf | grep "/usr/sbin/octo_scheduler" | grep -v grep`;
  $result{'Scheduler'} = scalar(@lines);

  return (%result);
}

=head2 Timestamp_Version($conf)

Returns timestamp => yyyymmddxxxx

=cut

sub Timestamp_Version
{
  my $conf = shift;
  my ($year, $mon, $mday) = AAT::Datetime::Now();

  my $version = 1;
  if (AAT::NOT_NULL($conf->{version})
    && ($conf->{version} =~ /^$year$mon$mday(\d{4})/))
  {
    $version = $1 + 1;
  }
  $version = AAT::Padding($version, 4);

  return ("$year$mon$mday$version");
}

=head2 Updates_Installation(@updates)

Installs Updates

=cut

sub Updates_Installation
{
  my @updates  = @_;
  my $web      = Octopussy::WebSite();
  my $dir_main = Octopussy::Directory('main');

  foreach my $u (@updates)
  {
    AAT::Download('Octopussy', "$web/Download/System/$u.xml",
      "$dir_main/$u.xml");
  }

  return (1);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
