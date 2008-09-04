=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut
package Octopussy::Configuration;

use strict;

use Octopussy;

use constant DIR_BACKUP => "/etc/octopussy/";

=head1 FUNCTIONS

=head2 Backup()

=cut
sub Backup()
{
	my ($year, $mon, $mday, $h, $m) = AAT::Datetime::Now();
	my $timestamp = "$year$mon$mday$h$m";
	my $file_backup = DIR_BACKUP . "backup_$timestamp.tgz";
	my $dir_main = Octopussy::Directory("main");
	my $conf_sys = "${dir_main}{db,ldap,nsca,proxy,smtp,xmpp}.xml";
	my $conf_alerts = Octopussy::Directory("alerts");
	my $conf_contacts = Octopussy::Directory("contacts");
	my $conf_devices = Octopussy::Directory("devices");
	my $conf_maps = Octopussy::Directory("maps");
	my $conf_plugins = Octopussy::Directory("plugins");
	my $conf_reports = Octopussy::Directory("reports");
	my $conf_search_templates = Octopussy::Directory("search_templates");
	my $conf_services = Octopussy::Directory("services");
	my $conf_tables = Octopussy::Directory("tables");
	my $conf_devicegroup = Octopussy::File("devicegroups");
	my $conf_locations = Octopussy::File("locations");
	my $conf_schedule = Octopussy::File("schedule");
	my $conf_servicegroup = Octopussy::File("servicegroups");
	my $conf_storages = Octopussy::File("storages");
	my $conf_timeperiods = Octopussy::File("timeperiods");
	my $conf_users = Octopussy::File("users");

	`tar Picvfz $file_backup $conf_sys $conf_alerts $conf_contacts $conf_devices $conf_maps $conf_plugins $conf_reports $conf_search_templates $conf_services $conf_tables $conf_devicegroup $conf_locations $conf_schedule $conf_servicegroup $conf_storages $conf_timeperiods $conf_users`;

	return ($file_backup);
}

=head2 Backup_List()

Returns List of Backup Files

=cut
sub Backup_List()
{
	my @backups = ();
	
	my @list = AAT::FS::Directory_Files(DIR_BACKUP, qr/^backup_.+$/);
	foreach my $e (reverse sort @list)
	{ 
		push(@backups, { label => "Backup $2/$3/$4 $5:$6", value => $1 })	
			if ($e =~ /(backup_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2}))\.tgz/); 
	}

	return (@backups);
}

=head2 Restore($file)

Restores configuration from Backup File '$file'

=cut
sub Restore($)
{
	my $file = shift;
	my $file_backup = DIR_BACKUP . "${file}.tgz";
	`tar Pxvfz $file_backup`;	
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
