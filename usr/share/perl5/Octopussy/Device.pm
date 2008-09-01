=head1 NAME

Octopussy::Device - Octopussy Device module

=cut

package Octopussy::Device;

use strict;
use Octopussy;

use constant STOPPED => 0;
use constant PAUSED => 1;
use constant STARTED => 2;
use constant DEVICE_DIR => "devices";

my $PARSER_BIN = "octo_parser";
my $UPARSER_BIN = "octo_uparser";
my $devices_dir = undef;
my $pid_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New($conf)

Creates a new device

=cut
sub New($)
{
	my $conf = shift;
	my $name = $conf->{name};

	if (AAT::NOT_NULL($name))
	{	
		$devices_dir ||= Octopussy::Directory(DEVICE_DIR);
		$conf->{type} = $conf->{type} || Octopussy::Parameter("devicetype");
		$conf->{model} = $conf->{model} || Octopussy::Parameter("devicemodel");
		$conf->{status} = "Paused";
		$conf->{logrotate} = Octopussy::Parameter("logrotate");
		AAT::XML::Write("$devices_dir/$name.xml", $conf, "octopussy_device");
		Octopussy::Chown("$devices_dir/$name.xml");
		Octopussy::Logs::Init_Directories($name);
	}
}

=head2 Modify($new_conf)

Modifies the configuration of a device

=cut
sub Modify($)
{
	my $new_conf = shift;
	my $status = Parse_Status($new_conf->{name});
	my $conf = AAT::XML::Read(Filename($new_conf->{name}));
	my $old_status = $conf->{status};
  Parse_Pause($new_conf->{name})  if ($status == STARTED);
	$devices_dir ||= Octopussy::Directory(DEVICE_DIR);
	$conf->{logtype} = $new_conf->{logtype} || "syslog";
	$conf->{type} = $new_conf->{type} || Octopussy::Parameter("devicetype");
	$conf->{async} = $new_conf->{async} || undef;
  $conf->{model} = $new_conf->{model} || Octopussy::Parameter("devicemodel");
	$conf->{description} = $new_conf->{description} || "";
	$conf->{status} = $new_conf->{status} || $old_status || "Paused";
	$conf->{city} = $new_conf->{city} || "";
	$conf->{building} = $new_conf->{building} || "";
	$conf->{room} = $new_conf->{room} || "";
	$conf->{rack} = $new_conf->{rack} || "";
	$conf->{logrotate} = $new_conf->{logrotate} || "";
	$conf->{minutes_without_logs} = $new_conf->{minutes_without_logs} || "";
	AAT::XML::Write("$devices_dir/$conf->{name}.xml", $conf, "octopussy_device");
	Parse_Start($new_conf->{name})	if ($status == STARTED);
}

=head2 Reload_Required($device)

Sets 'reload_required' to Device '$device'

=cut
sub Reload_Required($)
{
	my $device = shift;

	my $conf = AAT::XML::Read(Filename($device));	
	$conf->{reload_required} = 1;
	AAT::XML::Write("$devices_dir/$conf->{name}.xml", $conf, "octopussy_device");
}

=head2 Remove($device)

Removes device '$device'

=cut
sub Remove($)
{
	my $device = shift;

	Octopussy::Device::Parse_Stop($device);
	Octopussy::DeviceGroup::Remove_Device($device);
	Octopussy::Logs::Remove_Directories($device);
	my $web_dir = Octopussy::Directory("web");
	`rm -rf $web_dir/rrd/taxonomy_${device}_*ly.png`;
	my $rrd_dir = Octopussy::Directory("data_rrd");
	`rm -rf $rrd_dir/$device/`;
	unlink(Filename($device));
  $filenames{$device} = undef;
}

=head2 List()

Gets List of Devices

=cut
sub List()
{
	$devices_dir ||= Octopussy::Directory(DEVICE_DIR);

	return (AAT::XML::Name_List($devices_dir));
}

=head2 Filename($device_name)

Gets the XML filename for the device '$device_name'

=cut
sub Filename($)
{
	my $device_name = shift;

	return ($filenames{"$device_name"})		if (defined $filenames{"$device_name"});
	$devices_dir ||= Octopussy::Directory(DEVICE_DIR);
	$filenames{"$device_name"} = "$devices_dir/$device_name.xml"; 

 	return ($filenames{"$device_name"});
}

=head2 Configuration($device_name)

Gets the configuration for the device '$device_name'

=cut
sub Configuration($)
{
	my $device_name = shift;

	my $conf = AAT::XML::Read(Filename($device_name));
	$conf->{type} = Octopussy::Parameter("devicetype")	
		if ((defined $conf) && (!defined $conf->{type}));
	
	return ($conf);
}

=head2 Configurations($sort)

Gets the configuration for all devices 

=cut
sub Configurations
{
	my $sort = shift || "name";
	my (@configurations, @sorted_configurations) = ((), ());
	my @devices = List();
	my %field;

	foreach my $d (@devices)
	{
		my $conf = Configuration($d);
		my $status = Octopussy::Device::Parse_Status($conf->{name});
		$conf->{status} = ($status == 2 ? "Started" : ($status == 1 ? "Paused" : "Stopped"));
		$conf->{action1} = ($conf->{status} eq "Stopped" 
			? "parse_pause" : "parse_stop");
		$conf->{action2} = ($conf->{status} eq "Started" 
			? "parse_pause" : "parse_start");
		$conf->{logtype} ||= "syslog"; 
		$field{$conf->{$sort}} = 1;
		push(@configurations, $conf);
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)		if ($c->{$sort} eq $f); }	
	}	

	return (@sorted_configurations);
}

=head2 Filtered_Configurations($sort)

Gets the configuration for devices filtered by DeviceType/Model 

=cut
sub Filtered_Configurations($$$)
{
	my ($type, $model, $sort) = @_;
	my (@configurations, @sorted_configurations) = ((), ());
	my @devices = List();
	my %field;

	foreach my $d (@devices)
	{
		my $conf = Configuration($d);
		if (((AAT::NULL($type)) || ($type eq "-ANY-") || ($type eq $conf->{type}))
			&& ((AAT::NULL($model)) || ($model eq "-ANY-") || ($model eq $conf->{model})))
		{
			my $status = Octopussy::Device::Parse_Status($conf->{name});
			$conf->{status} = ($status == 2 ? "Started" : ($status == 1 ? "Paused" : "Stopped"));
			$conf->{action1} = ($conf->{status} eq "Stopped" 
				? "parse_pause" : "parse_stop");
			$conf->{action2} = ($conf->{status} eq "Started" 
				? "parse_pause" : "parse_start");
			$conf->{logtype} ||= "syslog"; 
			$field{$conf->{$sort}} = 1;
			push(@configurations, $conf);
		}
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)		if ($c->{$sort} eq $f); }	
	}	

	return (@sorted_configurations);
}

=head2 Add_Service($device, $service)

Adds Service or Servicegroup '$service' to Device '$device'

=cut
sub Add_Service($$)
{
	my ($device, $service) = @_;

	my $conf = AAT::XML::Read(Filename($device));
	foreach my $dev_serv (AAT::ARRAY($conf->{service}))
  	{ return()	if ($dev_serv->{sid} =~ /^$service$/); }

	my $old_status = Parse_Status($device);
  Parse_Pause($device)  if ($old_status == STARTED);
  my $rank = AAT::Padding(($#{$conf->{service}} + 2), 2);
	if ($service =~ /^group (.+)$/)
	{
		foreach my $s (Octopussy::ServiceGroup::Services($1))
		{	
			my $exists = 0;
			foreach my $dev_serv (AAT::ARRAY($conf->{service}))
				{ $exists = 1	if ($dev_serv->{sid} =~ /^$s->{sid}$/); }
			if (! $exists)
			{
				push(@{$conf->{service}}, { sid => $s->{sid}, rank => $rank });
				$rank++;
			}
		}
	}
	else
		{ push(@{$conf->{service}}, { sid => $service, rank => $rank }); }
	AAT::XML::Write(Filename($device), $conf, "octopussy_device");
	Parse_Start($device)  if ($old_status == STARTED);
}

=head2 Remove_Service($device_name, $service_name)

Removes a service '$service_name' from device '$device_name'

=cut
sub Remove_Service($$)
{
	my ($device_name, $service_name) = @_;
	my $old_status = Parse_Status($device_name);
	Parse_Pause($device_name)	if ($old_status == STARTED);

	my @services = ();
	my $rank = undef;
	my $conf = AAT::XML::Read(Filename($device_name));
	foreach my $s (AAT::ARRAY($conf->{service}))
 	{
		if ($s->{sid} ne $service_name)
			{ push(@services, $s); }
		else
			{ $rank = $s->{rank}; }
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
  my $rrd_dir = Octopussy::Directory("data_rrd");
  `rm -f $rrd_dir/$device_name/taxonomy_$service_name.rrd`;
 	$conf->{service} = \@services;
	AAT::XML::Write(Filename($device_name), $conf, "octopussy_device");
	Parse_Start($device_name)  if ($old_status == STARTED);
}

=head2 Move_Service($device, $service, $direction)

Moves Service '$service' into Device '$device' Services List 
in Direction Top, Bottom, Up or Down ('$direction')

=cut
sub Move_Service($$$)
{
	my ($device, $service, $direction) = @_;
	my $old_status = Parse_Status($device);
  my ($rank, $old_rank) = (undef, undef);
	my $conf = AAT::XML::Read(Filename($device));
  my @services = ();
	my $max = (defined $conf->{service} ? $#{$conf->{service}}+1 : 0);
  $max = AAT::Padding($max, 2);
  foreach my $s (AAT::ARRAY($conf->{service}))
  {
    if ($s->{sid} eq $service)
    {
			return () if (($s->{rank} eq "01") && ($direction eq "up"));
      return () if (($s->{rank} eq "$max") && ($direction eq "down"));
			$old_rank = $s->{rank};
      $s->{rank} = ($direction eq "top" ? 1 
				: ($direction eq "up" ? $s->{rank} - 1 
				: ($direction eq "down" ? $s->{rank} + 1 : $max)));
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
					{ $s->{rank} += 1; }
				elsif (($direction =~ /^bottom$/) && ($s->{rank} > $old_rank))
					{ $s->{rank} -= 1; }
			}
    	elsif ($s->{rank} eq $rank)
    	{
      	$s->{rank} = ($direction =~ /^up$/ ? $s->{rank} + 1 : $s->{rank} - 1);
    	}
		}
		$s->{rank} = AAT::Padding($s->{rank}, 2);
    push(@services2, $s);
  }
  $conf->{service} = \@services2;
	$conf->{reload_required} = 1;
	AAT::XML::Write(Filename($device), $conf, "octopussy_device");
}

=head2 Services(@devices)

Gets Service list from Device list '@devices'

=cut
sub Services
{
	my @devices = @_;
	my @services = ();
	my %tmp = ();
	
	foreach my $d (@devices)
	{
		return (Octopussy::Service::List())	if ($d =~ /^-ANY-$/i);
		my $conf = AAT::XML::Read(Filename($d));
		my %field;
		foreach my $s (AAT::ARRAY($conf->{service}))
			{ $field{$s->{rank}} = 1; }
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

=head2 Services_Configurations($device_name, $sort)

=cut
sub Services_Configurations($$)
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
    foreach my $c (@configurations)
      { push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
  }

  return (@sorted_configurations);
}

=head2 Services_Statistics($device)

=cut
sub Services_Statistics($)
{
	my $device = shift;
	my %stats;

	my $file = Octopussy::Device_Stats_File($device);  
	my $total = 0;
	if (defined open(STATS, "< $file"))
	{
  	while (<STATS>)
  	{
			$stats{$1} = $2	if ($_ =~ /^(.+): (\d+)$/); 
			$total += $2;
  	}
  	close(STATS);
	}
	else
	{
		my ($pack, $pack_file, $line, $sub) = caller(0);
    AAT::Syslog("Octopussy::Device", "Unable to open file '$file' in $sub");
	}
	foreach my $k (keys %stats)
	{
		$stats{$k} = ($total == 0 ? "0%" : (int($stats{$k} * 100 / $total) . "%"));
	}

	return (%stats);
}

=head2 With_Service($service)

Returns List of Device which have Service '$service' in its Devices List

=cut
sub With_Service($)
{
	my $service = shift;
	my @configurations = Configurations("name");
	my @devices = ();

	foreach my $c (@configurations)
	{
		foreach my $s (AAT::ARRAY($c->{service}))
			{ push(@devices, $c->{name})	if ($s->{sid} eq $service);	}
	}

	return (@devices);
}

=head2 Types()

Returns Device Types List

=cut
sub Types()
{
	my $conf = AAT::XML::Read(Octopussy::File("device_models"));
 	my @list = ();
 	foreach my $t (AAT::ARRAY($conf->{device_type}))
 		{ push(@list, $t->{dt_id}); }

	return (@list);
}

=head2 Type_Configurations()

=cut
sub Type_Configurations()
{
  my $conf = AAT::XML::Read(Octopussy::File("device_models"));
  my %type = ();
  foreach my $t (AAT::ARRAY($conf->{device_type}))
  	{ $type{$t->{dt_id}} = $t; }

	return (%type);
}

=head2 Models($type)

Returns Device Models List

=cut
sub Models($)
{
	my $type = shift;
 	my $conf = AAT::XML::Read(Octopussy::File("device_models"));
 	my @list = ();

	foreach my $t (AAT::ARRAY($conf->{device_type}))
  {
		if ($t->{dt_id} eq $type)
		{
			foreach my $m (AAT::ARRAY($t->{device_model}))
  		{
				push(@list, { name => $m->{dm_id}, icon => $m->{icon}, 
					footprint => $m->{footprint} } );
			}
		}
  }

	return (@list);
}

=head2 Parse_Status($device)

Returns Parsing status of the Device '$device'

=cut
sub Parse_Status($)
{
	my $device = shift;

	my $conf = Configuration($device);
	if (defined $conf)
	{
		$pid_dir ||= Octopussy::Directory("running");
		my @files = AAT::FS::Directory_Files($pid_dir, qr/^octo_parser_$device\.pid$/);

		return ($#files >= 0 ? 2 : 
			(((defined $conf->{status}) && ($conf->{status} eq "Stopped")) ? 0 : 1));
	}

	return (undef);
}

=head2 Parse_Pause($device)

Pauses Parsing for Device '$device'

=cut
sub Parse_Pause($)
{
	my $device = shift;

	$pid_dir ||= Octopussy::Directory("running");
	my $pid_file = "$pid_dir/${PARSER_BIN}_${device}.pid";
	if (-f $pid_file)
	{
  	my $pid = `cat "$pid_file"`;
  	chomp($pid);
  	kill USR1 => $pid;
#		unlink("$pid_file");
	}

	$pid_file = "$pid_dir/${UPARSER_BIN}_${device}.pid";
	if (-f $pid_file)
  {
  	my $pid = `cat "$pid_file"`;
  	chomp($pid);
  	kill USR1 => $pid;
	}

	$devices_dir ||= Octopussy::Directory(DEVICE_DIR);
	my $conf = Configuration($device);
	if (defined $conf)
	{
		$conf->{status} = "Paused";
		AAT::XML::Write("$devices_dir/$conf->{name}.xml", 
			$conf, "octopussy_device");
	}
}

=head2 Parse_Start($device)

Starts Parsing for Device '$device'

=cut
sub Parse_Start($)
{
	my $device = shift;
	my $base = Octopussy::Directory("programs");
	my $conf = Configuration($device);

	if (defined $conf)
	{
		system("$base$PARSER_BIN $device &");
		$devices_dir ||= Octopussy::Directory(DEVICE_DIR);	
		Octopussy::Dispatcher_Reload()	if ($conf->{status} eq "Stopped");
		$conf->{status} = "Started";
		$conf->{reload_required} = undef;
		AAT::XML::Write("$devices_dir/$conf->{name}.xml",       
			$conf, "octopussy_device");
	}
}

=head2 Parse_Stop($device)

Stops Parsing for Device '$device'

=cut
sub Parse_Stop($)
{
	my $device = shift;

	Parse_Pause($device);
	my $conf = Configuration($device);
	if (defined $conf)
	{
		$conf->{status} = "Stopped";
		$devices_dir ||= Octopussy::Directory(DEVICE_DIR);
		AAT::XML::Write("$devices_dir/$conf->{name}.xml",       
			$conf, "octopussy_device");
		Octopussy::Dispatcher_Reload();
	}
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
