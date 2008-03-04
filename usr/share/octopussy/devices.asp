<WebUI:PageTop title="Devices" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
my $dtype = $f->{device_type} || $Request->QueryString("dtype");
my $dmodel = $f->{device_model};
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("devices_table_sort");	

if (!defined $device)
{
	#print "filter dtype=$f->{device_type} dmodel=$f->{device_model}";
	#<AAT:Inc file="octo_devices_filter_box" url="./devices.asp" 
	#	dtype="$dtype" dmodel="$dmodel" />
	%><AAT:Inc file="octo_devices_list" url="./devices.asp" 
		dtype="$dtype" dmodel="$dmodel" sort="$sort" /><%
}
else
{
	if ((!-f Octopussy::Device::Filename($device)) && (AAT::NOT_NULL($device))
			&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Device::New({ name => $device, address => $f->{address}, 
			logtype => $f->{logtype}, type => $f->{device_type}, 
			model => $f->{device_model}, description => $f->{description} });
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Device", $device);
		$Response->Redirect("./device_services.asp?device=$device");
	}
	$Response->Redirect("./device_services.asp?device=$device")
		if (!defined $action);
	if ($Session->{AAT_ROLE} !~ /ro/i)
	{
		if ($action eq "remove")
		{
			Octopussy::Device::Remove($device);
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Device", $device);
		}
		if ($action eq "parse_start")
		{
			Octopussy::Device::Parse_Start($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "started", $device);
		}
		if ($action eq "parse_pause")
		{
			Octopussy::Device::Parse_Pause($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "paused", $device);
		}
		if ($action eq "parse_stop")
		{
			Octopussy::Device::Parse_Stop($device);
			AAT::Syslog("octo_WebUI", "PARSING_DEVICE", "stopped", $device);
		}
		$Response->Redirect("./devices.asp");
	}
}
%>
<WebUI:PageBottom />
