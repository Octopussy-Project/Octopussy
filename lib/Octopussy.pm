
=head1 NAME

Octopussy - Octopussy main module

=cut

package Octopussy;

use strict;
use warnings;

use File::Basename;
use File::Path;
use Proc::PID::File;
use POSIX qw( mkfifo strftime );

use AAT::Application;
use AAT::Download;
use AAT::Syslog;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy::Cache;
use Octopussy::FS;
use Octopussy::Info;

my $APPLICATION_NAME = 'Octopussy';
my $SF_SITE          = 'http://sourceforge.net/projects/syslog-analyzer/files/';
my $IDX_STAT_UID     = 4;
my $IDX_STAT_GID     = 5;

our $VERSION = '1.0.14';

=head1 FUNCTIONS

=head2 Version()

Returns Octopussy main module Version

=cut

sub Version
{
    return ($Octopussy::VERSION);
}

=head2 Commander($cmd)

Add command $cmd to octo_commander commands list

=cut

sub Commander
{
    my $cmd = shift;

    my $cache = Octopussy::Cache::Init('octo_commander');
    if (defined $cache)
    {
        my $commands = $cache->get('commands') || ();
        push @{$commands}, $cmd;
        $cache->set('commands', $commands);

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

    AAT::Syslog::Message($prog_name, $msg);
    die $msg;
}

=head2 Error

Syslogs error and prints it

=cut

sub Error
{
    my ($module, $msg, @args) = @_;

    my $message = AAT::Syslog::Message($module, $msg, @args);
    print "$module: $message\n";

    return ("$module: $message\n");
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

    my $cache  = Octopussy::Cache::Init($bin);
    my $status = $cache->get("status_$param");

    return ($status);
}

=head2 Sourceforge_Version()

Get version of the last release on Sourceforge

=cut

sub Sourceforge_Version
{
    my $dir_running = Octopussy::FS::Directory('running');
    my $version     = undef;
    
	AAT::Download::File($APPLICATION_NAME, $SF_SITE,
        "${dir_running}/octopussy.sf_version");
    if (defined open my $UPDATE, '<', "${dir_running}/octopussy.sf_version")
    {
        while (<$UPDATE>)
        {
            $version = $1
                if ($_ =~ /<span>Download octopussy-(\S+)\.tar\.gz/);
        }
        close $UPDATE;
        unlink "${dir_running}octopussy.sf_version";
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
    my $website     = Octopussy::Info::WebSite();
    my $dir_running = Octopussy::FS::Directory('running');
    AAT::Download::File('Octopussy', "$website/Download/$type/$file",
        "$dir_running$file");
    if (defined open my $UPDATE, '<', "$dir_running$file")
    {
        while (<$UPDATE>) { $update{$1} = $2 if ($_ =~ /^(.+):(\d+)$/); }
        close $UPDATE;
        unlink "$dir_running$file";
    }

    return (\%update);
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
        Octopussy::FS::Create_Directory($dir);
        mkfifo($fifo, '0700');
        Octopussy::FS::Chown($fifo);
    }

    return ($fifo);
}

=head2 PID_File

Returns PID File

=cut

sub PID_File
{
    my $name = shift;

    my $dir_pid  = Octopussy::FS::Directory('running');
    my $file_pid = $dir_pid . $name . '.pid';
    my $user     = Octopussy::Info::User();

    my $line = `id $user`;
    if ($line =~ /uid=(\d+)\($user\) gid=(\d+)\($user\)/)
    {
        my ($uid, $gid) = ($1, $2);
        my @attr = stat $file_pid;

        if (
            (-f $file_pid)
            && (   ($uid != $attr[$IDX_STAT_UID])
                || ($gid != $attr[$IDX_STAT_GID]))
           )
        {
            AAT::Syslog::Message('octopussy',
                "ERROR: pid file '$file_pid' doesn't match octopussy uid/gid !"
            );
        }
        else
        {
            return (undef)
                if (Proc::PID::File->running(dir => $dir_pid, name => $name));
        }
    }

    return ($file_pid);
}

=head2 PID_Value

=cut

sub PID_Value
{
    my $file  = shift;
    my $value = undef;

    if (defined open my $F_PID, '<', $file)
    {
        $value = <$F_PID>;
        chomp $value;
        close $F_PID;
    }

    return ($value);
}

=head2 Dialog($id)

Returns Dialog properties for the Dialog '$id'

=cut

sub Dialog
{
    my $id = shift;

    my $conf = AAT::XML::Read(Octopussy::FS::File('dialogs'));
    foreach my $d (ARRAY($conf->{dialog}))
    {
        return ($d) if ($d->{d_id} eq $id);
    }

    return (undef);
}

=head2 Process_Status()

Returns Status of Processes syslog-ng, dispatcher & scheduler

=cut

sub Process_Status
{
    my %result = ();

    my @syslogng_lines = `ps -edf | grep "syslog-ng" | grep -v grep`;
    my @rsyslog_lines  = `ps -edf | grep "rsyslog" | grep -v grep`;

    if (scalar(@syslogng_lines) > scalar(@rsyslog_lines))
    {
        $result{"Syslog-ng"} = scalar(@syslogng_lines);
    }
    else
    {
        $result{'Rsyslog'} = scalar @rsyslog_lines;
    }

    my @lines = `ps -edf | grep "/usr/sbin/octo_dispatcher" | grep -v grep`;
    $result{'Dispatcher'} = scalar @lines;
    @lines = `ps -edf | grep "/usr/sbin/octo_scheduler" | grep -v grep`;
    $result{'Scheduler'} = scalar @lines;

    return (%result);
}

=head2 Timestamp_Version($conf)

Returns timestamp => yyyymmddxxxx

=cut

sub Timestamp_Version
{
    my $conf = shift;
    my $date = strftime("%Y%m%d", localtime);

    my $version = 1;
    if (NOT_NULL($conf->{version})
        && ($conf->{version} =~ /^$date(\d{4})/))
    {
        $version = $1 + 1;
    }
    $version = sprintf("%04d", $version);

    return ("$date$version");
}

=head2 Updates_Installation(@updates)

Installs Updates

=cut

sub Updates_Installation
{
    my @updates  = @_;
    my $web      = Octopussy::Info::WebSite();
    my $dir_main = Octopussy::FS::Directory('main');

    foreach my $u (@updates)
    {
        AAT::Download::File('Octopussy', "$web/Download/System/$u.xml",
            "$dir_main/$u.xml");
    }

    return (1);
}

=head2 Waiting_For_Process_Already_Running($prog_name, $device)

Waits (max 10 secs) for already running process to stop

=cut

sub Waiting_For_Process_Already_Running
{
    my ($prog_name, $device) = @_;

    my $file_pid = PID_File("${prog_name}_${device}");
    my $count    = 0;
    while ((!defined $file_pid) && ($count < 10))
    {    # wait 10 secs max that old parser stops
        sleep 1;
        $count++;
        $file_pid = PID_File("${prog_name}_${device}");
    }
    if (!defined $file_pid)
    {
        Die($prog_name,
            "[CRITICAL] Parsing $device - Process already running !");
    }
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
