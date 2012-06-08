<WebUI:PageTop title="_DEVICES" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
$device = (Octopussy::Device::Valid_Name($device) ? $device : undef);
my $dtype = $f->{device_type} || $Request->QueryString("dtype");
my $dmodel = $f->{device_model_filter};
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("devices_table_sort");	

$Session->{AAT_PAGE_CURRENT} = 
	"./devices.asp" . (NOT_NULL($sort) ? "?devices_table_sort=$sort" : "");

if (NULL($device))
{
	if (($action eq "parse_reload_all") && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
  {
  	my @dconfs = Octopussy::Device::Configurations();
   	foreach my $dc (@dconfs)
   	{
    	my $status = Octopussy::Device::Parse_Status($dc->{name});
     	if ((NOT_NULL($dc->{reload_required})) && ($status == 2))
      {
      	Octopussy::Device::Parse_Pause($dc->{name});
        Octopussy::Device::Parse_Start($dc->{name});
       	AAT::Syslog::Message("octo_WebUI", "PARSING_DEVICE", "reload", $dc->{name}, $Session->{AAT_LOGIN});
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
	if ((NOT_NULL($device) && (!-f Octopussy::Device::Filename($device)))
			&& ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
	{
		Octopussy::Device::New({ name => $device, address => $f->{address}, 
      description => Encode::decode_utf8($f->{description}),
			logtype => $f->{logtype}, type => $f->{device_type}, 
			model => $f->{device_model} });
		AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Device", $device, $Session->{AAT_LOGIN});
		$Response->Redirect("./device_services.asp?device=$device");
	}
	$Response->Redirect("./device_services.asp?device=$device")
		if (NULL($action));
	if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
	{
		if ($action eq "remove")
		{
			Octopussy::Device::Remove($device);
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Device", $device, $Session->{AAT_LOGIN});
		}
		elsif ($action eq "parse_reload")
    {
      Octopussy::Device::Parse_Pause($device);
			Octopussy::Device::Parse_Start($device);
      AAT::Syslog::Message("octo_WebUI", "PARSING_DEVICE", "reload", $device, $Session->{AAT_LOGIN});
    }
		elsif ($action eq "parse_start")
		{
			Octopussy::Device::Parse_Start($device);
			AAT::Syslog::Message("octo_WebUI", "PARSING_DEVICE", "started", $device, $Session->{AAT_LOGIN});
		}
		elsif ($action eq "parse_pause")
		{
			Octopussy::Device::Parse_Pause($device);
			AAT::Syslog::Message("octo_WebUI", "PARSING_DEVICE", "paused", $device, $Session->{AAT_LOGIN});
		}
		elsif ($action eq "parse_stop")
		{
			Octopussy::Device::Parse_Stop($device);
			AAT::Syslog::Message("octo_WebUI", "PARSING_DEVICE", "stopped", $device, $Session->{AAT_LOGIN});
		}
		
		$Response->Redirect("./devices.asp");
	}
}
%>
<WebUI:PageBottom />
