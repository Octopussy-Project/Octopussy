# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Device - Octopussy Device module

=cut

package Octopussy::Device;

use strict;
use warnings;
use Readonly;

use File::Path qw(rmtree);
use List::MoreUtils qw(uniq);
use POSIX qw(strftime);

use AAT::FS;
use AAT::Utils qw( ARRAY NOT_NULL NULL );
use AAT::XML;
use Octopussy;
use Octopussy::Cache;
use Octopussy::DeviceGroup;
use Octopussy::FS;
use Octopussy::Logs;
use Octopussy::Service;
use Octopussy::ServiceGroup;
use Octopussy::System;

Readonly my $PAUSED            => 1;
Readonly my $STARTED           => 2;
Readonly my $PERCENT           => 100;
Readonly my $DIR_DEVICE        => 'devices';
Readonly my $PARSER_BIN        => 'octo_parser';
Readonly my $UPARSER_BIN       => 'octo_uparser';
Readonly my $FILE_DEVICEMODELS => 'device_models';
Readonly my $XML_ROOT          => 'octopussy_device';

my ($dir_devices, $dir_pid) = (undef, undef);
my %filename;

=head1 FUNCTIONS

=head2 New($conf)

Creates a new Device

=cut

sub New
{
  my $conf = shift;
  my $name = $conf->{name};

  if (NOT_NULL($name))
  {
    $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
    Octopussy::FS::Create_Directory($dir_devices);
    $conf->{type}  = $conf->{type}  || Octopussy::Parameter('devicetype');
    $conf->{model} = $conf->{model} || Octopussy::Parameter('devicemodel');
    $conf->{status}    = 'Paused';
    $conf->{logrotate} = Octopussy::Parameter('logrotate');
    AAT::XML::Write("$dir_devices/$name.xml", $conf, $XML_ROOT);
    Octopussy::FS::Chown("$dir_devices/$name.xml");
    Octopussy::Logs::Init_Directories($name);
  }

  return ($name);
}

=head2 Modify($conf_new)

Modifies the configuration of a Device

=cut

sub Modify
{
  my $conf_new   = shift;
  my $status     = Parse_Status($conf_new->{name});
  my $conf       = AAT::XML::Read(Filename($conf_new->{name}));
  my $old_status = $conf->{status};
  Parse_Pause($conf_new->{name}) if ($status == $STARTED);
  $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
  $conf->{logtype} = $conf_new->{logtype} || 'syslog';
  $conf->{type}    = $conf_new->{type}    || Octopussy::Parameter('devicetype');
  $conf->{async}   = $conf_new->{async}   || '';
  $conf->{model} = $conf_new->{model} || Octopussy::Parameter('devicemodel');
  $conf->{description} = $conf_new->{description} || '';
  $conf->{status}      = $conf_new->{status}      || $old_status || 'Paused';
  $conf->{city}        = $conf_new->{city}        || '';
  $conf->{building}    = $conf_new->{building}    || '';
  $conf->{room}        = $conf_new->{room}        || '';
  $conf->{rack}        = $conf_new->{rack}        || '';
  $conf->{logrotate}   = $conf_new->{logrotate}   || '';
  $conf->{minutes_without_logs} = $conf_new->{minutes_without_logs} || '';
  AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
  Parse_Start($conf_new->{name}) if ($status == $STARTED);

  return (undef);
}

=head2 Reload_Required($device)

Sets 'reload_required' to Device '$device'

=cut

sub Reload_Required
{
  my $device = shift;

  my $conf = AAT::XML::Read(Filename($device));
  $conf->{reload_required} = 1;
  AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);

  return ($device);
}

=head2 Remove($device)

Removes device '$device'

=cut

sub Remove
{
  my $device = shift;

  Octopussy::Device::Parse_Pause($device);
  Octopussy::DeviceGroup::Remove_Device($device);
  Octopussy::Logs::Remove_Directories($device);
  my $dir_web = Octopussy::FS::Directory('web');
  system "rm -f $dir_web/rrd/taxonomy_${device}_*ly.png";
  my $dir_rrd = Octopussy::FS::Directory('data_rrd');
  File::Path::rmtree("$dir_rrd/$device/");
  unlink Filename($device);
  $filename{$device} = undef;
  Octopussy::System::Dispatcher_Reload();

  return ($device);
}

=head2 List()

Gets List of Devices

=cut

sub List
{
  $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);

  return (AAT::XML::Name_List($dir_devices));
}

=head2 String_List

Returns Device List as a string like 'Device list: <device_list>'

=cut

sub String_List
{
  my $any     = shift;
  my @list    = List();
  my $str_any = (NOT_NULL($any) ? '-ANY-, ' : '');

  return ("Device list: $str_any" . (join ', ', sort @list));
}

=head2 Unknowns(@devices)

Returns list of Unknown Devices in @devices list

=cut

sub Unknowns
{
  my @devices  = @_;
  my @unknowns = ();

  my %exist = map { $_ => 1 } List();
  foreach my $d (@devices)
  {
    push @unknowns, $d if ((!defined $exist{$d}) && ($d ne '-ANY-'));
  }

  return (@unknowns);
}

=head2 Filename($device_name)

Gets the XML filename for the device '$device_name'

=cut

sub Filename
{
  my $device_name = shift;

  return ($filename{"$device_name"}) if (defined $filename{"$device_name"});
  $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
  $filename{"$device_name"} = "$dir_devices/$device_name.xml";

  return ($filename{"$device_name"});
}

=head2 Configuration($device_name)

Gets the configuration for the device '$device_name'

=cut

sub Configuration
{
  my $device_name = shift;

  my $conf = AAT::XML::Read(Filename($device_name));
  if ((defined $conf) && (!defined $conf->{type}))
  {
    $conf->{type} = Octopussy::Parameter('devicetype');
  }

  return ($conf);
}

=head2 Configurations($sort)

Gets the configuration for all devices 

=cut

sub Configurations
{
  my $sort = shift || 'name';
  my (@configurations, @sorted_configurations) = ((), ());
  my @devices = List();

  foreach my $d (@devices)
  {
    my $conf   = Configuration($d);
    my $status = Octopussy::Device::Parse_Status($conf->{name});
    $conf->{status} = (
      $status == $STARTED
      ? 'Started'
      : ($status == $PAUSED ? 'Paused' : 'Stopped')
    );
    $conf->{action1} =
      ($conf->{status} eq 'Stopped' ? 'parse_pause' : 'parse_stop');
    $conf->{action2} =
      ($conf->{status} eq 'Started' ? 'parse_pause' : 'parse_start');
    $conf->{logtype} ||= 'syslog';
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Filtered_Configurations($type, $model, $sort)

Gets the configuration for devices filtered by DeviceType/Model 

=cut

sub Filtered_Configurations
{
  my ($type, $model, $sort) = @_;
  my (@configurations, @sorted_configurations) = ((), ());
  my @devices = List();

  foreach my $d (@devices)
  {
    my $conf = Configuration($d);
    if (
      ((NULL($type)) || ($type eq '-ANY-') || ($type eq $conf->{type}))
      && ( (NULL($model))
        || ($model eq '-ANY-')
        || ($model eq $conf->{model}))
       )
    {
      my $status = Octopussy::Device::Parse_Status($conf->{name});
      $conf->{status} = (
        $status == $STARTED
        ? 'Started'
        : ($status == $PAUSED ? 'Paused' : 'Stopped')
      );
      $conf->{action1} =
        ($conf->{status} eq 'Stopped' ? 'parse_pause' : 'parse_stop');
      $conf->{action2} =
        ($conf->{status} eq 'Started' ? 'parse_pause' : 'parse_start');
      $conf->{logtype} ||= 'syslog';
      push @configurations, $conf;
    }
  }

  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Add_Service($device, $service)

Adds Service or Servicegroup '$service' to Device '$device'

=cut

sub Add_Service
{
  my ($device, $service) = @_;

  my $conf = AAT::XML::Read(Filename($device));
  foreach my $dev_serv (ARRAY($conf->{service}))
  {
    return () if ($dev_serv->{sid} =~ /^$service$/);
  }

  my $old_status = Parse_Status($device);
  Parse_Pause($device) if ($old_status == $STARTED);
  my $rank = sprintf(
    "%02d",
    (
      NOT_NULL($conf->{service})
      ? (scalar(@{$conf->{service}}) + 1)
      : 1
    )
  );
  if ($service =~ /^group (.+)$/)
  {
    foreach my $s (Octopussy::ServiceGroup::Services($1))
    {
      my $exists = 0;
      foreach my $dev_serv (ARRAY($conf->{service}))
      {
        $exists = 1 if ($dev_serv->{sid} =~ /^$s->{sid}$/);
      }
      if (!$exists)
      {
        push @{$conf->{service}}, {sid => $s->{sid}, rank => $rank};
        $rank++;
      }
    }
  }
  else { push @{$conf->{service}}, {sid => $service, rank => $rank}; }
  AAT::XML::Write(Filename($device), $conf, $XML_ROOT);
  Parse_Start($device) if ($old_status == $STARTED);

  return (scalar @{$conf->{service}});
}

=head2 Remove_Service($device_name, $service_name)

Removes a service '$service_name' from device '$device_name'

=cut

sub Remove_Service
{
  my ($device_name, $service_name) = @_;
  my $old_status = Parse_Status($device_name);
  Parse_Pause($device_name) if ($old_status == $STARTED);

  my @services = ();
  my $rank     = undef;
  my $conf     = AAT::XML::Read(Filename($device_name));
  foreach my $s (ARRAY($conf->{service}))
  {
    if ($s->{sid} ne $service_name) { push @services, $s; }
    else                            { $rank = $s->{rank}; }
  }
  foreach my $s (@services)
  {
    if ($s->{rank} > $rank)
    {
      $s->{rank} -= 1;
      $s->{rank} = sprintf("%02d", $s->{rank});
    }
  }
  $service_name =~ s/ /_/g;
  my $dir_rrd = Octopussy::FS::Directory('data_rrd');
  system "rm -f $dir_rrd/$device_name/taxonomy_$service_name.rrd";
  $conf->{service} = \@services;
  AAT::XML::Write(Filename($device_name), $conf, $XML_ROOT);
  Parse_Start($device_name) if ($old_status == $STARTED);

  return (scalar @services);
}

=head2 Update_Services_Rank($conf, $service, $direction, $rank, $old_rank)

Updates Services Rank

=cut

sub Update_Services_Rank
{
  my ($conf, $service, $direction, $rank, $old_rank) = @_;

  my @services = ();
  foreach my $s (ARRAY($conf->{service}))
  {
    if ($s->{sid} ne $service)
    {
      if (($direction eq 'top') || ($direction eq 'bottom'))
      {
        if (($direction eq 'top') && ($s->{rank} < $old_rank))
        {
          $s->{rank} += 1;
        }
        elsif (($direction eq 'bottom') && ($s->{rank} > $old_rank))
        {
          $s->{rank} -= 1;
        }
      }
      elsif ($s->{rank} eq $rank)
      {
        $s->{rank} = ($direction eq 'up' ? $s->{rank} + 1 : $s->{rank} - 1);
      }
    }
    $s->{rank} = sprintf("%02d", $s->{rank});
    push @services, $s;
  }

  return (@services);
}

=head2 Move_Service($device, $service, $direction)

Moves Service '$service' into Device '$device' Services List 
in Direction Top, Bottom, Up or Down ('$direction')

=cut

sub Move_Service
{
  my ($device, $service, $direction) = @_;
  my ($rank, $old_rank) = (undef, undef);
  my $conf     = AAT::XML::Read(Filename($device));
  my @services = ();
  my $max      = (defined $conf->{service} ? scalar(@{$conf->{service}}) : 0);
  $max = sprintf("%02d", $max);
  foreach my $s (ARRAY($conf->{service}))
  {

    if ($s->{sid} eq $service)
    {
      return () if (($s->{rank} eq '01') && ($direction eq 'up'));
      return () if (($s->{rank} eq $max) && ($direction eq 'down'));
      $old_rank = $s->{rank};
      $s->{rank} = (
        $direction eq 'top' ? 1
        : (
          $direction eq 'up' ? $s->{rank} - 1
          : ($direction eq 'down' ? $s->{rank} + 1 : $max)
        )
      );
      $s->{rank} = sprintf("%02d", $s->{rank});
      $rank = $s->{rank};
    }
    push @services, $s;
  }
  $conf->{service} = \@services;

  my @services2 =
    Update_Services_Rank($conf, $service, $direction, $rank, $old_rank);
  $conf->{service}         = \@services2;
  $conf->{reload_required} = 1;
  AAT::XML::Write(Filename($device), $conf, $XML_ROOT);

  return ($rank);
}

=head2 Services(@devices)

Gets Service list (sorted by rank) from Device list '@devices'

=cut

sub Services
{
  my @devices  = @_;
  my @services = ();

  foreach my $d (@devices)
  {
    return (Octopussy::Service::List()) if ($d eq '-ANY-');
    my $conf = AAT::XML::Read(Filename($d));
    foreach my $s (sort { $a->{rank} cmp $b->{rank} } ARRAY($conf->{service}))
    {
      push @services, $s->{sid};
    }
  }

  return (@services);
}

=head2 String_Services

Returns Service List as a string like 'Service list: <service_list>'

=cut 

sub String_Services
{
  my @devices = @_;

  my @unknowns = Unknowns(@devices);
  if (scalar @unknowns)
  {
    return (sprintf '[ERROR] Unknown Device(s): %s', join ', ', @unknowns);
  }
  my @services = sort(uniq(Services(@devices)));

  return ('Service list: -ANY-, ' . join ', ', @services);
}

=head2 Services_Configurations($device, $sort)

Returns Services Configurations sorted by '$sort' field for Device '$device'

=cut

sub Services_Configurations
{
  my ($device, $sort) = @_;
  my @configurations = ();
  my $conf           = AAT::XML::Read(Filename($device));

  foreach my $s (sort { $a->{rank} cmp $b->{rank} } ARRAY($conf->{service}))
  {
    push @configurations, $s;
  }

  return (@configurations);
}

=head2 Services_Statistics($device)

=cut

sub Services_Statistics
{
  my $device = shift;
  my %stats;

  my $timestamp    = strftime("%Y%m%d%H%M", localtime);
  my $limit        = int($timestamp) - Octopussy::Parameter('msgid_history');
  my $cache_parser = Octopussy::Cache::Init('octo_parser');
  my $total        = 0;
  foreach my $k (sort $cache_parser->get_keys())
  {
    if ( ($k =~ /^parser_msgid_stats_(\d{12})_(\S+)$/)
      && ($1 >= $limit)
      && ($2 eq $device))
    {
      my $data = $cache_parser->get($k);
      foreach my $s (@{$data})
      {
        if ($s->{id} eq 'TOTAL')
        {
          $stats{$s->{service}} = (
            defined $stats{$s->{service}}
            ? $stats{$s->{service}} + $s->{count}
            : $s->{count}
          );
          $total += $s->{count};
        }
      }
    }
  }
  foreach my $k (keys %stats)
  {
    $stats{$k} =
      ($total == 0 ? 0 : sprintf '%.1f%%', ($stats{$k} * $PERCENT / $total));
  }

  return (%stats);
}

=head2 With_Service($service)

Returns List of Device which have Service '$service' in its Services List

=cut

sub With_Service
{
  my $service        = shift;
  my @configurations = Configurations('name');
  my @devices        = ();

  foreach my $c (@configurations)
  {
    foreach my $s (ARRAY($c->{service}))
    {
      push @devices, $c->{name} if ($s->{sid} eq $service);
    }
  }

  return (@devices);
}

=head2 Types()

Returns Device Types List

=cut

sub Types
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_DEVICEMODELS));
  my @list = ();
  foreach
    my $t (sort { $a->{dt_id} cmp $b->{dt_id} } ARRAY($conf->{device_type}))
  {
    push @list, $t->{dt_id};
  }

  return (@list);
}

=head2 Type_Configurations()

=cut

sub Type_Configurations
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_DEVICEMODELS));
  my %type = ();
  foreach my $t (ARRAY($conf->{device_type}))
  {
    $type{$t->{dt_id}} = $t;
  }

  return (%type);
}

=head2 Models($type)

Returns Device Models List

=cut

sub Models
{
  my $type = shift;
	$type ||= 'Unknown';
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_DEVICEMODELS));
  my @list = ();

  foreach
    my $t (sort { $a->{dt_id} cmp $b->{dt_id} } ARRAY($conf->{device_type}))
  {
    if ($t->{dt_id} eq $type)
    {
      foreach
        my $m (sort { $a->{dm_id} cmp $b->{dm_id} } ARRAY($t->{device_model}))
      {
        push @list,
          {
          name      => $m->{dm_id},
          icon      => $m->{icon},
          footprint => $m->{footprint}
          };
      }
    }
  }

  return (@list);
}

=head2 Parse_Status($device)

Returns Parsing status of the Device '$device'

=cut

sub Parse_Status
{
  my $device = shift;

  my $conf = Configuration($device);
  if (defined $conf)
  {
    $dir_pid ||= Octopussy::FS::Directory('running');
    my @files =
      AAT::FS::Directory_Files($dir_pid, qr/^octo_parser_$device\.pid$/);

    return (
      scalar(@files) > 0 ? 2
      : (
        ((defined $conf->{status}) && ($conf->{status} eq 'Stopped')) ? 0
        : 1
      )
    );
  }

  return (undef);
}

=head2 Parse_Pause($device)

Pauses Parsing for Device '$device'

=cut

sub Parse_Pause
{
  my $device = shift;

  $dir_pid ||= Octopussy::FS::Directory('running');
  my $file_pid = "$dir_pid/${PARSER_BIN}_${device}.pid";
  if (-f $file_pid)
  {
    my $pid = Octopussy::PID_Value($file_pid);
    kill USR1 => $pid;
  }

  $file_pid = "$dir_pid/${UPARSER_BIN}_${device}.pid";
  if (-f $file_pid)
  {
    my $pid = Octopussy::PID_Value($file_pid);
    kill USR1 => $pid;
  }

  $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
  my $conf = Configuration($device);
  if (defined $conf)
  {
    $conf->{status} = 'Paused';
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
  }

  return ($device);
}

=head2 Parse_Start($device)

Starts Parsing for Device '$device'

=cut

sub Parse_Start
{
  my $device = shift;
  my $base   = Octopussy::FS::Directory('programs');
  my $conf   = Configuration($device);

  if (defined $conf)
  {
    my $cmd = "$base$PARSER_BIN $device &";
    Octopussy::Commander($cmd);
    $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
    Octopussy::System::Dispatcher_Reload() if ($conf->{status} eq 'Stopped');
    $conf->{status}          = 'Started';
    $conf->{reload_required} = undef;
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
  }

  return ($device);
}

=head2 Parse_Stop($device)

Stops Parsing for Device '$device'

=cut

sub Parse_Stop
{
  my $device = shift;

  Parse_Pause($device);
  my $conf = Configuration($device);
  if (defined $conf)
  {
    $conf->{status} = 'Stopped';
    $dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
    Octopussy::System::Dispatcher_Reload();
  }

  return ($device);
}

=head2 Set_Service_Option($device, $service, $option, $action)

Set Service Option (compression or statistics) to enable or disable

=cut

sub Set_Service_Option
{
	my ($device, $service, $option, $action) = @_;

  	my $status   = ($action eq 'enable' ? 1 : 0);
  	my $conf     = Configuration($device);
  	my @services = ();
  	foreach my $s (ARRAY($conf->{service}))
  	{
    	$s->{$option} = $status if ($s->{sid} eq $service);
    	push @services, $s;
  	}
	$conf->{service}         = \@services;
  	$conf->{reload_required} = 1;
  	$dir_devices ||= Octopussy::FS::Directory($DIR_DEVICE);
  	AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);

  	return ($status);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for a Device name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1)  
		if ((NOT_NULL($name)) && (($name =~ /^[a-z][a-z0-9_-]*$/i) 
			|| ($name =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
