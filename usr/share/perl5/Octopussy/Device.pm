
=head1 NAME

Octopussy::Device - Octopussy Device module

=cut

package Octopussy::Device;

use strict;
use warnings;
use Readonly;

use Octopussy;

Readonly my $PAUSED            => 1;
Readonly my $STARTED           => 2;
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

  if (AAT::NOT_NULL($name))
  {
    $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
    $conf->{type}  = $conf->{type}  || Octopussy::Parameter('devicetype');
    $conf->{model} = $conf->{model} || Octopussy::Parameter('devicemodel');
    $conf->{status}    = 'Paused';
    $conf->{logrotate} = Octopussy::Parameter('logrotate');
    AAT::XML::Write("$dir_devices/$name.xml", $conf, $XML_ROOT);
    Octopussy::Chown("$dir_devices/$name.xml");
    Octopussy::Logs::Init_Directories($name);
  }
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
  $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
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
  my $dir_web = Octopussy::Directory('web');
  system("rm -f $dir_web/rrd/taxonomy_${device}_*ly.png");
  my $dir_rrd = Octopussy::Directory('data_rrd');
  File::Path::rmtree("$dir_rrd/$device/");
  unlink(Filename($device));
  $filename{$device} = undef;
  Octopussy::Dispatcher_Reload();
}

=head2 List()

Gets List of Devices

=cut

sub List
{
  $dir_devices ||= Octopussy::Directory($DIR_DEVICE);

  return (AAT::XML::Name_List($dir_devices));
}

=head2 String_List

=cut

sub String_List
{
  my $any     = shift;
  my @list    = List();
  my $str_any = (AAT::NOT_NULL($any) ? '-ANY-, ' : '');

  return ("Device list: $str_any" . (join(', ', sort @list)));
}

=head2 Filename($device_name)

Gets the XML filename for the device '$device_name'

=cut

sub Filename
{
  my $device_name = shift;

  return ($filename{"$device_name"}) if (defined $filename{"$device_name"});
  $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
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
  my %field;

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
    $field{$conf->{$sort}} = 1;
    push(@configurations, $conf);
  }
  foreach my $f (sort keys %field)
  {
    push(@sorted_configurations, grep { $_->{$sort} eq $f } @configurations);
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
  my %field;

  foreach my $d (@devices)
  {
    my $conf = Configuration($d);
    if (
      ((AAT::NULL($type)) || ($type eq '-ANY-') || ($type eq $conf->{type}))
      && ( (AAT::NULL($model))
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
      $field{$conf->{$sort}} = 1;
      push(@configurations, $conf);
    }
  }
  foreach my $f (sort keys %field)
  {
    push(@sorted_configurations, grep { $_->{$sort} eq $f } @configurations);
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
  foreach my $dev_serv (AAT::ARRAY($conf->{service}))
  {
    return () if ($dev_serv->{sid} =~ /^$service$/);
  }

  my $old_status = Parse_Status($device);
  Parse_Pause($device) if ($old_status == $STARTED);
  my $rank = AAT::Padding(
    (AAT::NOT_NULL($conf->{service}) ? (scalar(@{$conf->{service}}) + 1) : 1),
    2);
  if ($service =~ /^group (.+)$/)
  {
    foreach my $s (Octopussy::ServiceGroup::Services($1))
    {
      my $exists = 0;
      foreach my $dev_serv (AAT::ARRAY($conf->{service}))
      {
        $exists = 1 if ($dev_serv->{sid} =~ /^$s->{sid}$/);
      }
      if (!$exists)
      {
        push(@{$conf->{service}}, {sid => $s->{sid}, rank => $rank});
        $rank++;
      }
    }
  }
  else { push(@{$conf->{service}}, {sid => $service, rank => $rank}); }
  AAT::XML::Write(Filename($device), $conf, $XML_ROOT);
  Parse_Start($device) if ($old_status == $STARTED);
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
  foreach my $s (AAT::ARRAY($conf->{service}))
  {
    if ($s->{sid} ne $service_name) { push(@services, $s); }
    else                            { $rank = $s->{rank}; }
  }
  foreach my $s (@services)
  {
    if ($s->{rank} > $rank)
    {
      $s->{rank} -= 1;
      $s->{rank} = AAT::Padding($s->{rank}, 2);
    }
  }
  $service_name =~ s/ /_/g;
  my $dir_rrd = Octopussy::Directory('data_rrd');
  system("rm -f $dir_rrd/$device_name/taxonomy_$service_name.rrd");
  $conf->{service} = \@services;
  AAT::XML::Write(Filename($device_name), $conf, $XML_ROOT);
  Parse_Start($device_name) if ($old_status == $STARTED);
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
  $max = AAT::Padding($max, 2);
  foreach my $s (AAT::ARRAY($conf->{service}))
  {

    if ($s->{sid} eq $service)
    {
      return () if (($s->{rank} eq '01')   && ($direction eq 'up'));
      return () if (($s->{rank} eq "$max") && ($direction eq 'down'));
      $old_rank = $s->{rank};
      $s->{rank} = (
        $direction eq 'top' ? 1
        : (
          $direction eq 'up' ? $s->{rank} - 1
          : ($direction eq 'down' ? $s->{rank} + 1 : $max)
        )
      );
      $s->{rank} = AAT::Padding($s->{rank}, 2);
      $rank = $s->{rank};
    }
    push(@services, $s);
  }
  $conf->{service} = \@services;
  my @services2 = ();
  foreach my $s (AAT::ARRAY($conf->{service}))
  {
    if ($s->{sid} ne $service)
    {
      if ($direction =~ /^(top|bottom)$/)
      {
        if (($direction =~ /^top$/) && ($s->{rank} < $old_rank))
        {
          $s->{rank} += 1;
        }
        elsif (($direction =~ /^bottom$/) && ($s->{rank} > $old_rank))
        {
          $s->{rank} -= 1;
        }
      }
      elsif ($s->{rank} eq $rank)
      {
        $s->{rank} = ($direction =~ /^up$/ ? $s->{rank} + 1 : $s->{rank} - 1);
      }
    }
    $s->{rank} = AAT::Padding($s->{rank}, 2);
    push(@services2, $s);
  }
  $conf->{service}         = \@services2;
  $conf->{reload_required} = 1;
  AAT::XML::Write(Filename($device), $conf, $XML_ROOT);
}

=head2 Services(@devices)

Gets Service list from Device list '@devices'

=cut

sub Services
{
  my @devices  = @_;
  my @services = ();

  foreach my $d (@devices)
  {
    return (Octopussy::Service::List()) if ($d =~ /^-ANY-$/i);
    my $conf = AAT::XML::Read(Filename($d));
    my %field;
    foreach my $s (AAT::ARRAY($conf->{service})) { $field{$s->{rank}} = 1; }
    foreach my $f (sort keys %field)
    {
      foreach my $s (AAT::ARRAY($conf->{service}))
      {
        push(@services, $s->{sid}) if ($s->{rank} eq $f);
      }
    }
  }

  return (@services);
}

=head2 String_Services

=cut 

sub String_Services
{
  my @devices  = @_;
  my @services = Services(@devices);
  @services = sort keys %{{map { $_ => 1 } @services}};  # sort unique @services

  return ('Service list: -ANY-, ' . join(', ', @services));
}

=head2 Services_Configurations($device_name, $sort)

=cut

sub Services_Configurations
{
  my ($device_name, $sort) = @_;
  my (@configurations, @sorted_configurations) = ((), ());
  my $conf = AAT::XML::Read(Filename($device_name));
  my %field;

  foreach my $s (AAT::ARRAY($conf->{service}))
  {
    $field{$s->{$sort}} = 1;
    push(@configurations, $s);
  }
  foreach my $f (sort keys %field)
  {
    push(@sorted_configurations, grep { $_->{$sort} eq $f } @configurations);
  }

  return (@sorted_configurations);
}

=head2 Services_Statistics($device)

=cut

sub Services_Statistics
{
  my $device = shift;
  my %stats;

  my ($y, $mon, $d, $h, $m) = AAT::Datetime::Now();
  my $limit = int("$y$mon$d$h$m") - Octopussy::Parameter('msgid_history');
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
        if ($s->{id} == 'TOTAL')
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
    $stats{$k} = ($total == 0 ? 0 : sprintf('%.1f', $stats{$k} * 100 / $total)) . '%';
  }

  return (%stats);
}

=head2 With_Service($service)

Returns List of Device which have Service '$service' in its Devices List

=cut

sub With_Service
{
  my $service        = shift;
  my @configurations = Configurations('name');
  my @devices        = ();

  foreach my $c (@configurations)
  {
    foreach my $s (AAT::ARRAY($c->{service}))
    {
      push(@devices, $c->{name}) if ($s->{sid} eq $service);
    }
  }

  return (@devices);
}

=head2 Types()

Returns Device Types List

=cut

sub Types
{
  my $conf = AAT::XML::Read(Octopussy::File($FILE_DEVICEMODELS));
  my @list = ();
  foreach my $t (AAT::ARRAY($conf->{device_type})) { push(@list, $t->{dt_id}); }

  return (@list);
}

=head2 Type_Configurations()

=cut

sub Type_Configurations
{
  my $conf = AAT::XML::Read(Octopussy::File($FILE_DEVICEMODELS));
  my %type = ();
  foreach my $t (AAT::ARRAY($conf->{device_type})) { $type{$t->{dt_id}} = $t; }

  return (%type);
}

=head2 Models($type)

Returns Device Models List

=cut

sub Models
{
  my $type = shift;
  my $conf = AAT::XML::Read(Octopussy::File($FILE_DEVICEMODELS));
  my @list = ();

  foreach my $t (AAT::ARRAY($conf->{device_type}))
  {
    if ($t->{dt_id} eq $type)
    {
      foreach my $m (AAT::ARRAY($t->{device_model}))
      {
        push(
          @list,
          {
            name      => $m->{dm_id},
            icon      => $m->{icon},
            footprint => $m->{footprint}
          }
        );
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
    $dir_pid ||= Octopussy::Directory('running');
    my @files =
      AAT::FS::Directory_Files($dir_pid, qr/^octo_parser_$device\.pid$/);

    return (
      scalar(@files) > 0
      ? 2
      : (((defined $conf->{status}) && ($conf->{status} eq 'Stopped')) ? 0 : 1)
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

  $dir_pid ||= Octopussy::Directory('running');
  my $file_pid = "$dir_pid/${PARSER_BIN}_${device}.pid";
  if (-f $file_pid)
  {
    my $pid = `cat "$file_pid"`;
    chomp($pid);
    kill USR1 => $pid;
  }

  $file_pid = "$dir_pid/${UPARSER_BIN}_${device}.pid";
  if (-f $file_pid)
  {
    my $pid = `cat "$file_pid"`;
    chomp($pid);
    kill USR1 => $pid;
  }

  $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
  my $conf = Configuration($device);
  if (defined $conf)
  {
    $conf->{status} = 'Paused';
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
  }
}

=head2 Parse_Start($device)

Starts Parsing for Device '$device'

=cut

sub Parse_Start
{
  my $device = shift;
  my $base   = Octopussy::Directory('programs');
  my $conf   = Configuration($device);

  if (defined $conf)
  {
    my $cmd = "$base$PARSER_BIN $device &";
    Octopussy::Commander($cmd);
    $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
    Octopussy::Dispatcher_Reload() if ($conf->{status} eq 'Stopped');
    $conf->{status}          = 'Started';
    $conf->{reload_required} = undef;
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
  }
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
    $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
    AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);
    Octopussy::Dispatcher_Reload();
  }
}

=head2 Set_Service_Statistics($device, $service, $action)

=cut

sub Set_Service_Statistics
{
  my ($device, $service, $action) = @_;

  my $status   = ($action eq 'enable' ? 1 : 0);
  my $conf     = Configuration($device);
  my @services = ();
  foreach my $s (AAT::ARRAY($conf->{service}))
  {
    $s->{statistics} = $status if ($s->{sid} eq $service);
    push(@services, $s);
  }
  $conf->{service}         = \@services;
  $conf->{reload_required} = 1;
  $dir_devices ||= Octopussy::Directory($DIR_DEVICE);
  AAT::XML::Write("$dir_devices/$conf->{name}.xml", $conf, $XML_ROOT);

  return ($status);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
