#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut

package Octopussy::Configuration;

use strict;

use Octopussy;

my $BACKUP_DIR = "/etc/octopussy";

=head1 FUNCTIONS

=head2 Backup()

=cut

sub Backup()
{
	my ($year, $mon, $mday, $h, $m) = AAT::Datetime::Now();
	my $timestamp = "$year$mon$mday$h$m";
	my $main_dir = Octopussy::Directory("main");
	my $sys_conf = "${main_dir}{db,ldap,nsca,proxy,smtp,xmpp}.xml";

	my $alerts_conf = Octopussy::Directory("alerts");
	my $contacts_conf = Octopussy::Directory("contacts");
	my $devices_conf = Octopussy::Directory("devices");
	my $maps_conf = Octopussy::Directory("maps");
	my $plugins_conf = Octopussy::Directory("plugins");
	my $reports_conf = Octopussy::Directory("reports");
	my $services_conf = Octopussy::Directory("services");
	my $tables_conf = Octopussy::Directory("tables");

	my $devicegroup_conf = Octopussy::File("devicegroups");
	my $locations_conf = Octopussy::File("locations");
	my $schedule_conf = Octopussy::File("schedule");
	my $servicegroup_conf = Octopussy::File("servicegroups");
	my $storages_conf = Octopussy::File("storages");
	my $timeperiods_conf = Octopussy::File("timeperiods");
	my $users_conf = Octopussy::File("users");

	`tar Picvfz $BACKUP_DIR/backup_$timestamp.tgz $sys_conf $alerts_conf $contacts_conf $devices_conf $maps_conf $plugins_conf $reports_conf $services_conf $tables_conf $devicegroup_conf $locations_conf $schedule_conf $servicegroup_conf $storages_conf $timeperiods_conf $users_conf`;

	return ("$BACKUP_DIR/backup_$timestamp.tgz");
}

=head2 Backup_List()

Returns List of Backup Files

=cut

sub Backup_List()
{
	my @backups = ();
	
	my @list = AAT::FS::Directory_Files("$BACKUP_DIR/", qr/^backup_.+$/);
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

	`tar Pxvfz $BACKUP_DIR/${file}.tgz`;	
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
