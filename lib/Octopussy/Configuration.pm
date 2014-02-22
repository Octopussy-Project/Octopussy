
=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut

package Octopussy::Configuration;

use strict;
use warnings;

use POSIX qw(strftime);

use AAT;
use AAT::FS;
use Octopussy::FS;

my $DIR_BACKUP = '/etc/octopussy/';

=head1 FUNCTIONS

=head2 Set_Backup_Directory($dir)

=cut

sub Set_Backup_Directory
{
    my $dir = shift;

    $DIR_BACKUP = $dir;

    return ($DIR_BACKUP);
}

=head2 Backup($filename)

=cut

sub Backup
{
    my $filename = shift;

    my $timestamp = strftime("%Y%m%d%H%M%S", localtime);
    Octopussy::FS::Create_Directory($DIR_BACKUP);
    my $file_backup = $filename || "${DIR_BACKUP}backup_$timestamp.tgz";

    my $dir_main = Octopussy::FS::Directory('main');
    my ($dirs, $files) = ('', '');

    foreach my $d (
        Octopussy::FS::Directories(
            'alerts',  'contacts', 'devices',          'maps',
            'plugins', 'reports',  'search_templates', 'services',
            'tables'
        )
        )
    {
        $dirs .= "$d " if (-d $d);
    }

    foreach my $f (
        Octopussy::FS::Files(
            'db',   'devicegroups', 'ldap',        'locations',
            'nsca', 'proxy',        'schedule',    'servicegroups',
            'smtp', 'storages',     'timeperiods', 'users',
            'xmpp'
        )
        )
    {
        $files .= "$f " if (-f $f);
    }

    system "tar Picfz $file_backup $dirs $files";

    return ($file_backup);
}

=head2 Backup_List()

Returns List of Backup Files

=cut

sub Backup_List
{
    my @backups = ();

    my @list = AAT::FS::Directory_Files($DIR_BACKUP, qr/^backup_.+$/);
    foreach my $e (reverse sort @list)
    {
        push @backups, {label => "Backup $2/$3/$4 $5:$6:$7", value => $1}
            if (
            $e =~ /(backup_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2}))\.tgz/);
    }

    return (@backups);
}

=head2 Restore($file)

Restores configuration from Backup File '$file'

=cut

sub Restore
{
    my $file        = shift;
    my $file_backup = "${DIR_BACKUP}${file}.tgz";
    system "tar Pxfz $file_backup";

    return (1);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
