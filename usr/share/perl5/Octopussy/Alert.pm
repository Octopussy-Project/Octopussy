=head1 NAME

Octopussy::Alert - Octopussy Alert module

=cut

package Octopussy::Alert;

use strict;
use utf8;
use Octopussy;

my @COMPARATORS = ("<", ">", "=", "<=", ">=", "LIKE");

my @LEVELS = ("Warning", "Critical");

my $ALERT_DIR = "alerts";

my $alerts_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New($conf)

Create a new alert and then restart parser for devices concerned

=cut

sub New($)
{
	my $conf = shift;
	my %devices = ();
	$alerts_dir ||= Octopussy::Directory($ALERT_DIR);
	AAT::XML::Write("$alerts_dir/$conf->{name}.xml", $conf, "octopussy_alert");

	if (${$conf->{device}}[0] =~ /-ANY-/i)
	{
		foreach my $d (Octopussy::Device::List())
			{ $devices{$d} = 1; }	
	}	
	else
	{
  	foreach my $d (AAT::ARRAY($conf->{device}))
		{
			if ($d =~ /group (.+)/)
			{
      	foreach my $dev (Octopussy::DeviceGroup::Devices($1))
        	{ $devices{$dev} = 1; }
    	}
			else
				{ $devices{$d} = 1; }
  	}	
	}
	foreach my $d (sort keys %devices)
	{
		Octopussy::Device::Parse_Pause($d);
		Octopussy::Device::Parse_Start($d);
	}
}

=head2 Modify($old_alert, $new_conf)

Modify the configuration for the alert '$old_alert'

=cut

sub Modify($$)
{
	my ($old_alert, $new_conf) = @_;
	Remove($old_alert);
	New($new_conf);
}

=head2 Remove($alert)

Removes the alert '$alert'

=cut
 
sub Remove($)
{
	my $alert = shift;

 	unlink(Filename($alert));
	$filenames{$alert} = undef;
}

=head2 List()

Get List of Alerts

=cut
 
sub List()
{
	$alerts_dir ||= Octopussy::Directory($ALERT_DIR);
	
	return (AAT::XML::Name_List($alerts_dir));
}

#
# Function: Comparators()
#
# Get alerts comparators
# 
sub Comparators()
{
	return (@COMPARATORS);
}

#
# Function: Levels()
#
# Get alerts levels
#
sub Levels()
{
	return (@LEVELS);
}

=head2 Filename($alert_name)

Get the XML filename for the alert '$alert_name'

=cut
 
sub Filename($)
{
	my $alert_name = shift;

	return ($filenames{$alert_name})  if (defined $filenames{$alert_name});
	$alerts_dir ||= Octopussy::Directory($ALERT_DIR);
	$filenames{$alert_name} =	"$alerts_dir/$alert_name.xml"; 

	return ($filenames{$alert_name});
}

=head2 Configuration($alert_name)

Get the configuration for the alert '$alert_name'

=cut
 
sub Configuration($)
{
	my $alert_name = shift;

 	my $conf = AAT::XML::Read(Filename($alert_name));

  return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all alerts

=cut

sub Configurations
{
	my $sort = shift || "name";
	my (@configurations, @sorted_configurations) = ((), ());
	my @alerts = List();
	my %field;

	foreach my $a (@alerts)
	{
		my $conf = Configuration($a);
		$field{$conf->{$sort}} = 1;
		push(@configurations, $conf);
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
	}

	return (@sorted_configurations);
}

=head2 For_Device($device)

Get Alerts related to Device '$device'

=cut

sub For_Device($)
{
	my $device = shift;
	my @alerts = ();

	foreach my $ac (Octopussy::Alert::Configurations())
	{
		my $match = 0;
		my %devices = ();
		foreach my $d (AAT::ARRAY($ac->{device}))
		{
			if ($d =~ /group (.+)/)
    	{
      	foreach my $dev (Octopussy::DeviceGroup::Devices($1))
        	{ $devices{$dev} = 1; }
    	}
    	else
      	{ $devices{$d} = 1; }			
		}
		foreach my $d (sort keys %devices)
		{ 
			if (($d =~ /^$device$/) || ($d =~ /^-ANY-$/))
			{
				my @services = Octopussy::Device::Services($d);
				foreach my $s (@services)
        {
					foreach my $acs (AAT::ARRAY($ac->{service}))
          	{ $match = 1  if (($s =~ /^$acs$/) || ($acs =~ /^-ANY-$/)); }
				}
			}
		}
		push(@alerts, $ac)	if (($ac->{status} =~ /^Enabled$/i) 
			&& (($ac->{type} =~ /Static/i) || ($match)));
	}

	return (@alerts);
}

=head2 Insert_In_DB($device, $alert, $line, $date)

=cut

sub Insert_In_DB($$$$)
{
	my ($device, $alert, $line, $date) = @_;
	
	my $datestr = Date::Manip::UnixDate(Date::Manip::ParseDate($date),
		"%Y/%m/%d %H:%M:%S");
	AAT::DB::Insert("Octopussy", "_alerts_",
		{ alert_id => $alert->{name}, date_time => $datestr, device => $device,
			level => $alert->{level}, log => $line } );
}

=head2 Check_All_Closed()

Checks if all Alerts are closed

=cut

sub Check_All_Closed()
{	
	my @result = AAT::DB::Query("Octopussy", "SELECT * FROM _alerts_ "
		. "WHERE status NOT LIKE 'Closed'");
	
	return ($#result < 0 ? 1 : 0);
}

=head2 Opened_List($device)

Returns List of Alerts with Status 'Opened'

=cut

sub Opened_List($)
{
	my $device = shift;
	
	my $query = "SELECT * FROM _alerts_ "	
		. "WHERE device='$device' AND status='Opened'";
	
	return (AAT::DB::Query("Octopussy", $query));
}

=head2 Update_Status($id, $status, $comment

Updates Alert with id '$id' to Status '$status' & with Comment '$comment'

=cut

sub Update_Status($$$)
{
	my ($id, $status, $comment) = @_;
	
	AAT::DB::Do("Octopussy", "UPDATE _alerts_ SET status='$status', "
		. "comment='$comment' WHERE log_id=$id");
}

#
# Function: Add_Message($alert_name, $msg_id, $repeat, $interval)
#
# Add message '$msg_id' to alert '$alert_name'
# 
# Parameters:
#
# - $alert_name: Alert name
# - $msg_id: Message Id to Add
#
sub Add_Message($$$$)
{
	my ($alert_name, $msg_id, $repeat, $interval) = @_;

	my $conf = AAT::XML::Read(Filename($alert_name));
	push(@{$conf->{message}}, 
	{ msg_id => $msg_id, repeat => $repeat, interval => $interval });
	AAT::XML::Write(Filename($alert_name), $conf, "octopussy_alert");
}

#
# Function: Remove_Message($alert_name, $msg_id)
#
# Removes message '$msg_id' from alert '$alert_name'
# 
# Parameters:
# 
# - $alert_name: Alert name
# - $msg_id: Message Id to Remove
# 
sub Remove_Message($$)
{
	my ($alert_name, $msg_id) = @_;
	
	my $conf = AAT::XML::Read(Filename($alert_name));
	my @messages = ();
  foreach my $m (AAT::ARRAY($conf->{message}))
  {
  	push(@messages, $m)       if ($m->{msg_id} ne $msg_id);
 	}
	$conf->{message} = \@messages;
	AAT::XML::Write(Filename($alert_name), $conf, "octopussy_alert");
}

#
# Function: Add_Message_Field($alert_name, $msg_id, $field, $comparator, $value)
#
# Add field '$field' to message '$msg_id' to alert '$alert_name'
# 
# Parameters:
# 
# - $alert_name: Alert name
# - $msg_id: Message Id
# - $field: Message Field to Add
# - $comparator: Message Field Comparator
# - $value: Message Field Value
#
sub Add_Message_Field($$$$$)
{
	my ($alert_name, $msg_id, $field, $comparator, $value) = @_;
	
	my $conf = AAT::XML::Read(Filename($alert_name));
	foreach my $m (AAT::ARRAY($conf->{message}))
 	{
   	if ($m->{msg_id} eq $msg_id)
		{
			push(@{$m->{field}}, { fname => $field, 
			comparator => $comparator, fvalue => $value });
			last;
		}
 	}
	AAT::XML::Write(Filename($alert_name), $conf, "octopussy_alert");
}

#
# Function: Remove_Message_Field($alert_name, $msg_id, $field, $comparator, $value)
#
# Removes field '$field' to message '$msg_id' to alert '$alert_name'
# 
# Parameters:
#
# - $alert_name: Alert name
# - $msg_id: Message Id
# - $field: Message Field to Remove
# - $comparator: Message Field Comparator
# - $value: Message Field Value
# 
sub Remove_Message_Field($$$$$)
{
	my ($alert_name, $msg_id, $field, $comparator, $value) = @_;

	my $conf = AAT::XML::Read(Filename($alert_name));
	foreach my $m (AAT::ARRAY($conf->{message}))
	{
  	if ($m->{msg_id} eq $msg_id)
   	{
			my @fields = ();
			foreach my $f (AAT::ARRAY($m->{field}))
			{
				push(@fields, $f)       
					if (($f->{fname} ne $field) || ($f->{comparator} ne $comparator) || ($f->{fvalue} ne $value));
			}
			$m->{field} = \@fields;	
			last;
		}
	}
	AAT::XML::Write(Filename($alert_name), $conf, "octopussy_alert");
}

#
# Function: Add_Action($alert_name, $type, $contact, $data)
#
# Add action to alert '$alert_name'
#
#	Parameters:
#
#	 - $alert_name: Alert name
#	 - $type: Action Type
#	 - $contact: Action Contact
#	 - $data: Action Data
#
sub Add_Action($$$$)
{
	my ($alert_name, $type, $contact, $data) = @_;

	my $conf = AAT::XML::Read(Filename($alert_name));
	push(@{$conf->{action}},
  	{ type => $type, contact => $contact, data => $data });
	AAT::XML::Write(Filename($alert_name), $conf, "octopussy_alert");
}

=head2 From_Device($device)

Returns Alerts generated by device '$device'

=cut

sub From_Device($$)
{
	my ($device, $status) = @_;
	my @alerts = ();
	my $query = "SELECT * FROM _alerts_ WHERE device='$device'";
	$query .= (defined $status ? " AND status='$status'" : "");
	@alerts = AAT::DB::Query("Octopussy", $query);	

	return (@alerts);
}

=head2 Message_Building($alert, $device, $line, $msg)

Builds Alert Message

=cut

sub Message_Building($$$$)
{
	my ($alert, $device, $line, $msg) = @_;
	my %field = Octopussy::Message::Fields_Values($msg, $line);
	
	my $subject = $alert->{msgsubject};
 	my $body = $alert->{msgbody};
 	$subject =~ s/__device__/$device/gi;
 	$subject =~ s/__alert__/$alert->{name}/gi;
 	$subject =~ s/__level__/$alert->{level}/gi;
  $subject =~ s/__log__/$line/gi;
	$subject =~ s/__field_(\w+)__/$field{$1}/gi;
 	$body =~ s/__device__/$device/gi;
 	$body =~ s/__alert__/$alert->{name}/gi;
 	$body =~ s/__level__/$alert->{level}/gi;
 	$body =~ s/__log__/$line/gi;
	$body =~ s/__field_(\w+)__/$field{$1}/gi;
 	$body =~ s/\\n/\n/gi;

	return ($subject, $body);
}

=head2 Tracker($al, $dev, $stat, $sort, $limit)

=cut

sub Tracker($$$$$)
{
	my ($al, $dev, $stat, $sort, $limit) = @_;
	$sort ||= "date_time";
	my $query = "SELECT * FROM _alerts_"
  . ((($al ne "") || ($dev ne "") || ($stat ne ""))
  ? " WHERE "
  . (($al ne "") ? "alert_id='$al'" : "")
  . (($dev ne "") ? (($al ne "") ? " AND " : "") . "device='$dev'" : "")
  . (($stat ne "") ? ((($al ne "") || ($dev ne "")) ? " AND " : "")
  . "status='$stat'" : "") : "")
  . " ORDER BY $sort " . ($sort ne "date_time" ? "ASC" : "DESC")
  . (AAT::NOT_NULL($limit) ? " LIMIT $limit" : "");
	my @alerts = AAT::DB::Query("Octopussy", $query);

	return (@alerts);	
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
