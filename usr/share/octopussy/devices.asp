<WebUI:PageTop title="_DEVICES" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
my $dtype = $f->{device_type} || $Request->QueryString("dtype");
my $dmodel = $f->{device_model_filter};
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("devices_table_sort");	

$Session->{AAT_PAGE_CURRENT} = 
	"./devices.asp" . (AAT::NOT_NULL($sort) ? "?devices_table_sort=$sort" : "");

if (AAT::NULL($device))
{
	if ($action eq "parse_reload_all")
  {
  	my @dconfs = Octopussy::Device::Configurations();
   	foreach my $dc (@dconfs)
   	{
    	my $status = Octopussy::Device::Parse_Status($dc->{name});
     	if ((AAT::NOT_NULL($dc->{reload_required})) && ($status == 2))
      {
      	Octopussy::Device::Parse_Pause($dc->{name});
        Octopussy::Device::Parse_Start($dc->{name});
       	AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "reload", $dc->{name});
      }
    }
		$Response->Redirect("./devices.asp");
	}
	else
	{
	%><AAT:Inc file="octo_devices_filter_box" url="./devices.asp" 
		dtype="$dtype" dmodel="$dmodel" />
	<AAT:Inc file="octo_devices_list" url="./devices.asp" 
		dtype="$dtype" dmodel="$dmodel" sort="$sort" /><%
	}
}
else
{
	if ((AAT::NOT_NULL($device) && (!-f Octopussy::Device::Filename($device)))
			&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Device::New({ name => $device, address => $f->{address}, 
      description => Encode::decode_utf8($f->{description}),
			logtype => $f->{logtype}, type => $f->{device_type}, 
			model => $f->{device_model} });
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Device", $device);
		$Response->Redirect("./device_services.asp?device=$device");
	}
	$Response->Redirect("./device_services.asp?device=$device")
		if (AAT::NULL($action));
	if ($Session->{AAT_ROLE} !~ /ro/i)
	{
		if ($action eq "remove")
		{
			Octopussy::Device::Remove($device);
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Device", $device);
		}
		elsif ($action eq "parse_reload")
    {
      Octopussy::Device::Parse_Pause($device);
			Octopussy::Device::Parse_Start($device);
      AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "reload", $device);
    }
		elsif ($action eq "parse_start")
		{
			Octopussy::Device::Parse_Start($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "started", $device);
		}
		elsif ($action eq "parse_pause")
		{
			Octopussy::Device::Parse_Pause($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "paused", $device);
		}
		elsif ($action eq "parse_stop")
		{
			Octopussy::Device::Parse_Stop($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "stopped", $device);
		}
		
		$Response->Redirect("./devices.asp");
	}
}
%>
<WebUI:PageBottom />
