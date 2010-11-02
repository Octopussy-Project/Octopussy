# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Alert - Octopussy Alert module

=cut

package Octopussy::Alert;

use strict;
use warnings;
use Readonly;
use bytes;
use utf8;

use AAT::DB;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy;
use Octopussy::Device;
use Octopussy::DeviceGroup;
use Octopussy::FS;
use Octopussy::Message;

Readonly my $DIR_ALERT   => 'alerts';
Readonly my $XML_ROOT    => 'octopussy_alert';
Readonly my @COMPARATORS => q(< > = <= >= LIKE);
Readonly my @LEVELS      => (
  {
    label => 'Warning',
    value => 'Warning',
    color => 'orange'
  },
  {
    label => 'Critical',
    value => 'Critical',
    color => 'red'
  }
);

my $dir_alerts = undef;
my %filename;

=head1 FUNCTIONS

=head2 New($conf)

Create a new Alert and then restart parser for Devices concerned

=cut

sub New
{
  my $conf = shift;
  
  return (undef)	if ($conf->{name} !~ /^[-_a-z0-9]+$/i);
  
  $dir_alerts ||= Octopussy::FS::Directory($DIR_ALERT);
  my $file_xml = "$dir_alerts/$conf->{name}.xml";
  $conf->{msgbody}     =~ s/\r\n/ \@\@\@ /g;
  $conf->{action_body} =~ s/\r\n/ \@\@\@ /g;

  if (defined AAT::XML::Write($file_xml, $conf, $XML_ROOT))
  {
    my %devices = ();
    if (${$conf->{device}}[0] =~ /-ANY-/i)
    {
      foreach my $d (Octopussy::Device::List()) { $devices{$d} = 1; }
    }
    else
    {
      foreach my $d (ARRAY($conf->{device}))
      {
        if ($d =~ /group (.+)/)
        {
          foreach my $dev (Octopussy::DeviceGroup::Devices($1))
          {
            $devices{$dev} = 1;
          }
        }
        else { $devices{$d} = 1; }
      }
    }
    foreach my $d (sort keys %devices)
    {
      Octopussy::Device::Parse_Pause($d);
      Octopussy::Device::Parse_Start($d);
    }
    return ($file_xml);
  }

  return (undef);
}

=head2 Modify($old_alert, $conf_new)

Modify the configuration for the Alert '$old_alert'

=cut

sub Modify
{
  my ($old_alert, $conf_new) = @_;

  Remove($old_alert);
  New($conf_new);

  return (undef);
}

=head2 Remove($alert)

Removes the alert '$alert'

=cut

sub Remove
{
  my $alert = shift;

  my $nb = unlink Filename($alert);
  $filename{$alert} = undef;

  return ($nb);
}

=head2 List()

Get List of Alerts

=cut

sub List
{
  $dir_alerts ||= Octopussy::FS::Directory($DIR_ALERT);

  return (AAT::XML::Name_List($dir_alerts));
}

=head2 Comparators()

Get alerts comparators

=cut

sub Comparators
{
  return (@COMPARATORS);
}

=head2 Levels()

Get alerts levels

=cut

sub Levels
{
  return (@LEVELS);
}

=head2 Filename($alert_name)

Get the XML filename for the alert '$alert_name'

=cut

sub Filename
{
  my $alert_name = shift;

  return ($filename{$alert_name}) if (defined $filename{$alert_name});
  $dir_alerts ||= Octopussy::FS::Directory($DIR_ALERT);
  $filename{$alert_name} = "$dir_alerts/$alert_name.xml";

  return ($filename{$alert_name});
}

=head2 Configuration($alert_name)

Get the configuration for the alert '$alert_name'

=cut

sub Configuration
{
  my $alert_name = shift;

  my $conf = AAT::XML::Read(Filename($alert_name));
  $conf->{msgbody}     =~ s/ \@\@\@ /\n/g if (defined $conf->{msgbody});
  $conf->{action_body} =~ s/ \@\@\@ /\n/g if (defined $conf->{action_body});

  return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all alerts

=cut

sub Configurations
{
  my $sort = shift || 'name';
  my (@configurations, @sorted_configurations) = ((), ());
  my @alerts = List();

  foreach my $a (@alerts)
  {
    my $conf = Configuration($a);
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 For_Device($device)

Get Alerts related to Device '$device'

=cut

sub For_Device
{
  my $device = shift;
  my @alerts = ();

  foreach my $ac (Octopussy::Alert::Configurations())
  {
    my $match   = 0;
    my %devices = ();
    foreach my $d (ARRAY($ac->{device}))
    {
      if ($d =~ /group (.+)/)
      {
        foreach my $dev (Octopussy::DeviceGroup::Devices($1))
        {
          $devices{$dev} = 1;
        }
      }
      else { $devices{$d} = 1; }
    }
    foreach my $d (sort keys %devices)
    {
      if (($d eq $device) || ($d eq '-ANY-'))
      {
        my @services = Octopussy::Device::Services($d);
        foreach my $s (@services)
        {
          foreach my $acs (ARRAY($ac->{service}))
          {
            $match = 1 if (($s eq $acs) || ($acs eq '-ANY-'));
          }
        }
      }
    }
    push @alerts, $ac
      if (($ac->{status} eq 'Enabled')
      && (($ac->{type} =~ 'Static') || ($match)));
  }

  return (@alerts);
}

=head2 Insert_In_DB($device, $alert, $line, $date)

=cut

sub Insert_In_DB
{
  my ($device, $alert, $line, $date) = @_;

	if ($date =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/)
	{
  	my $datestr = "$1/$2/$3 $4:$5:$6";
  AAT::DB::Insert(
    'Octopussy',
    '_alerts_',
    {
      alert_id  => $alert->{name},
      date_time => $datestr,
      device    => $device,
      level     => $alert->{level},
      log       => $line
    }
  );
  	return (1);
	}

  return (0);
}

=head2 Check_All_Closed()

Checks if all Alerts are closed

=cut

sub Check_All_Closed
{
  my @result = AAT::DB::Query('Octopussy',
    q(SELECT * FROM _alerts_ WHERE status NOT LIKE 'Closed'));

  return (scalar(@result) == 0 ? 1 : 0);
}

=head2 Opened_List($device)

Returns List of Alerts with Status 'Opened'

=cut

sub Opened_List
{
  my $device = shift;

  my $query =
    'SELECT * FROM _alerts_ ' . "WHERE device='$device' AND status='Opened'";

  return (AAT::DB::Query('Octopussy', $query));
}

=head2 Update_Status($id, $status, $comment

Updates Alert with id '$id' to Status '$status' & with Comment '$comment'

=cut

sub Update_Status
{
  my ($id, $status, $comment) = @_;

  AAT::DB::Do('Octopussy',
        "UPDATE _alerts_ SET status='$status', "
      . "comment='$comment' WHERE log_id=$id");

  return (1);
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
sub Add_Message
{
  my ($alert_name, $msg_id, $repeat, $interval) = @_;

  my $conf = AAT::XML::Read(Filename($alert_name));
  push @{$conf->{message}},
    {msg_id => $msg_id, repeat => $repeat, interval => $interval};
  AAT::XML::Write(Filename($alert_name), $conf, $XML_ROOT);

  return (scalar @{$conf->{message}});
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
sub Remove_Message
{
  my ($alert_name, $msg_id) = @_;

  my $conf = AAT::XML::Read(Filename($alert_name));
  my @messages =
    grep { $_->{msg_id} ne $msg_id } ARRAY($conf->{message});
  $conf->{message} = \@messages;
  AAT::XML::Write(Filename($alert_name), $conf, $XML_ROOT);

  return (scalar @messages);
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
sub Add_Message_Field
{
  my ($alert_name, $msg_id, $field, $comparator, $value) = @_;

  my $conf = AAT::XML::Read(Filename($alert_name));
  foreach my $m (ARRAY($conf->{message}))
  {
    if ($m->{msg_id} eq $msg_id)
    {
      push @{$m->{field}},
        {
        fname      => $field,
        comparator => $comparator,
        fvalue     => $value
        };
      last;
    }
  }
  AAT::XML::Write(Filename($alert_name), $conf, $XML_ROOT);

  return ($field);
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
sub Remove_Message_Field
{
  my ($alert_name, $msg_id, $field, $comparator, $value) = @_;
  my @fields = ();

  my $conf = AAT::XML::Read(Filename($alert_name));
  foreach my $m (ARRAY($conf->{message}))
  {
    if ($m->{msg_id} eq $msg_id)
    {
      foreach my $f (ARRAY($m->{field}))
      {
        push @fields, $f
          if (($f->{fname} ne $field)
          || ($f->{comparator} ne $comparator)
          || ($f->{fvalue} ne $value));
      }
      $m->{field} = \@fields;
      last;
    }
  }
  AAT::XML::Write(Filename($alert_name), $conf, $XML_ROOT);

  return (scalar @fields);
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
sub Add_Action
{
  my ($alert_name, $type, $contact, $data) = @_;

  my $conf = AAT::XML::Read(Filename($alert_name));
  push @{$conf->{action}}, {type => $type, contact => $contact, data => $data};
  AAT::XML::Write(Filename($alert_name), $conf, $XML_ROOT);

  return (scalar @{$conf->{action}});
}

=head2 From_Device($device)

Returns Alerts generated by device '$device'

=cut

sub From_Device
{
  my ($device, $status) = @_;
  my @alerts = ();
  my $query  = "SELECT * FROM _alerts_ WHERE device='$device'";
  $query .= (defined $status ? " AND status='$status'" : '');
  @alerts = AAT::DB::Query('Octopussy', $query);

  return (@alerts);
}

sub Message_Replace
{
  my ($str, $alert, $device, $line, $field) = @_;

  $str =~ s/__device__/$device/gi;
  $str =~ s/__alert__/$alert->{name}/gi;
  $str =~ s/__level__/$alert->{level}/gi;
  $str =~ s/__log__/$line/gi;
  $str =~ s/__field_(\w+)__/$field->{$1}/gi;

  return ($str);
}

=head2 Message_Building($alert, $device, $line, $msg)

Builds Alert Message

=cut

sub Message_Building
{
  my ($alert, $device, $line, $msg) = @_;
  my %field = Octopussy::Message::Fields_Values($msg, $line);

  my $subject     = $alert->{msgsubject}     || '';
  my $body        = $alert->{msgbody}        || '';
  my $host        = $alert->{action_host}    || '';    # For Nagios/Zabbix
  my $service     = $alert->{action_service} || '';    # For Nagios/Zabbix
  my $action_body = $alert->{action_body}    || '';    # For Nagios/Zabbix

  $subject = Message_Replace($subject, $alert, $device, $line, \%field);
  $body    = Message_Replace($body,    $alert, $device, $line, \%field);
  $body =~ s/\s*\@\@\@\s*/\n/g;
  $action_body = Message_Replace($action_body, $alert, $device, $line, \%field);
  $action_body =~ s/\s*\@\@\@\s*/\n/g;
  $host    = Message_Replace($host,    $alert, $device, $line, \%field);
  $service = Message_Replace($service, $alert, $device, $line, \%field);

  return ($subject, $body, $host, $service, $action_body);
}

=head2 Tracker($al, $dev, $stat, $sort, $limit)

=cut

sub Tracker
{
  my ($al, $dev, $stat, $sort, $limit) = @_;
  $sort ||= 'date_time';
  my $query = 'SELECT * FROM _alerts_'
    . (
    (($al ne '') || ($dev ne '') || ($stat ne ''))
    ? ' WHERE '
      . (($al ne '') ? "alert_id='$al'" : '')
      . (($dev ne '') ? (($al ne '') ? ' AND ' : '') . "device='$dev'" : '')
      . (
        ($stat ne '')
      ? ((($al ne '') || ($dev ne '')) ? ' AND ' : '') . "status='$stat'"
      : ''
      )
    : ''
    )
    . " ORDER BY $sort "
    . ($sort ne 'date_time' ? 'ASC' : 'DESC')
    . (NOT_NULL($limit) ? " LIMIT $limit" : '');
  my @alerts = AAT::DB::Query('Octopussy', $query);

  return (@alerts);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
