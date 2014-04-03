package Octopussy::Configuration;

=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut

use strict;
use warnings;

use File::Slurp;
use POSIX qw(strftime);

use AAT;
use Octopussy::FS;

my $DIR_BACKUP = '/etc/octopussy/';
my @DIRECTORIES_TO_BACKUP = qw/ 
	alerts
	contacts
	devices          
	maps
    plugins
	reports
	search_templates
	services
	tables
	/;
my @FILES_TO_BACKUP = qw/
	db
	devicegroups
	ldap
	locations
	nsca
	proxy
	schedule
	servicegroups
    smtp
	storages
	timeperiods
	users
	xmpp	
	/;

=head1 SUBROUTINES/METHODS

=head2 Set_Backup_Directory($dir)

Sets Backup directory

=cut

sub Set_Backup_Directory
{
    my $dir = shift;

    $DIR_BACKUP = $dir;

    return ($DIR_BACKUP);
}

=head2 Backup($filename)

Creates Backup file '$filename'

=cut

sub Backup
{
    my $filename = shift;

    my $timestamp = strftime("%Y%m%d%H%M%S", localtime);
    Octopussy::FS::Create_Directory($DIR_BACKUP);
    my $file_backup = $filename || "${DIR_BACKUP}backup_$timestamp.tgz";

    my $dir_main = Octopussy::FS::Directory('main');
    my ($dirs, $files) = ('', '');

    foreach my $d (Octopussy::FS::Directories(@DIRECTORIES_TO_BACKUP))
    {
        $dirs .= "$d " if (-d $d);
    }

    foreach my $f (Octopussy::FS::Files(@FILES_TO_BACKUP))
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

	return ()	if (! -r $DIR_BACKUP);

    my @list = grep { /^backup_.+$/ } read_dir($DIR_BACKUP);
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
