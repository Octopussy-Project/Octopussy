=head1 NAME

Octopussy::Configuration - Octopussy Configuration module

=cut

package Octopussy::Configuration;

use strict;

use Octopussy;

my $BACKUP_DIR = "/etc/octopussy";
my $SYSTEM_CONF = "/etc/octopussy/main.xml";

=head1 FUNCTIONS

=head2 Backup($year, $mon, $mday, $h, $m)

=cut

sub Backup($$$$$)
{
	my ($year, $mon, $mday, $h, $m) = AAT::Datetime::Now();

	my $timestamp = "$year$mon$mday$h$m";
	my $alerts_conf = Octopussy::Directory("alerts");
	my $contacts_conf = Octopussy::Directory("contacts");
	my $devices_conf = Octopussy::Directory("devices");
	my $maps_conf = Octopussy::Directory("maps");
	my $plugins_conf = Octopussy::Directory("plugins");
	my $reports_conf = Octopussy::Directory("reports");
	my $devicegroup_conf = Octopussy::File("devicegroups");
	my $locations_conf = Octopussy::File("locations");
	my $schedule_conf = Octopussy::File("schedule");
	my $timeperiods_conf = Octopussy::File("timeperiods");
	my $users_conf = Octopussy::File("users");
	
	`tar Pcvfz $BACKUP_DIR/backup_$timestamp.tgz $SYSTEM_CONF $alerts_conf $contacts_conf $devices_conf $maps_conf $plugins_conf $reports_conf $devicegroup_conf $locations_conf $schedule_conf $timeperiods_conf $users_conf`;
}

=head2 Backup_List()

=cut

sub Backup_List()
{
	my @backups = ();
	
	my @list = AAT::FS::Directory_Files("$BACKUP_DIR/", qr/^backup_.+$/);
	foreach my $e (@list)
		{ push(@backups, $1)	if ($e =~ /(backup_.+)\.tgz/); }

	return (@backups);
}

=head2 Restore($file)

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
