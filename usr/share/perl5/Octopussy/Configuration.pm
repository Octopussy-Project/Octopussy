# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut

package Octopussy::Configuration;

use strict;
use warnings;
use Readonly;

use POSIX qw(strftime);

use AAT;
use AAT::FS;
use Octopussy::FS;

Readonly my $DIR_BACKUP => '/etc/octopussy/';

=head1 FUNCTIONS

=head2 Backup()

=cut

sub Backup
{
  my $timestamp   = strftime("%Y%m%d%H%M", localtime);
  my $file_backup = "${DIR_BACKUP}backup_$timestamp.tgz";
  my $dir_main    = Octopussy::FS::Directory('main');
  my $conf_sys    = "${dir_main}{db,ldap,nsca,proxy,smtp,xmpp}.xml";
  my ($dir_alerts, $dir_contacts, $dir_devices, $dir_maps, $dir_plugins) =
    Octopussy::FS::Directories('alerts', 'contacts', 'devices', 'maps',
    'plugins');
  my ($dir_reports, $dir_search_templates, $dir_services, $dir_tables) =
    Octopussy::FS::Directories('reports', 'search_templates', 'services',
    'tables');
  my ($file_devicegroup, $file_locations, $file_schedule) =
    Octopussy::FS::Files('devicegroups', 'locations', 'schedule');
  my ($file_servicegroup, $file_storages, $file_timeperiods, $file_users) =
    Octopussy::FS::Files('servicegroups', 'storages', 'timeperiods', 'users');

  system
"tar Picfz $file_backup $conf_sys $dir_alerts $dir_contacts $dir_devices $dir_maps $dir_plugins $dir_reports $dir_search_templates $dir_services $dir_tables $file_devicegroup $file_locations $file_schedule $file_servicegroup $file_storages $file_timeperiods $file_users";

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
    push @backups, {label => "Backup $2/$3/$4 $5:$6", value => $1}
      if ($e =~ /(backup_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2}))\.tgz/);
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

Sebastien Thebert <octo.devel@gmail.com>

=cut
