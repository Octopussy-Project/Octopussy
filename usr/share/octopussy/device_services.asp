<WebUI:PageTop title="Device Services" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
my $service = $f->{service} || $Request->QueryString("service");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("device_services_table_sort") || "rank";

if (defined $service)
{
	if (($action eq "remove") && ($Session->{AAT_ROLE} !~ /ro/i))
		{ Octopussy::Device::Remove_Service($device, $service);  }
	elsif ($action eq "show")
		{ $Response->Redirect("./services.asp?service=$service"); }
	elsif ((($action eq "up") || ($action eq "down")) 
					&& ($Session->{AAT_ROLE} !~ /ro/i))
  	{ Octopussy::Device::Move_Service($device, $service, $action); }
	elsif ($Session->{AAT_ROLE} !~ /ro/i)
		{ Octopussy::Device::Add_Service($device, $service); }
}
%>
<AAT:Inc file="octo_device_services_list" 
	url="./device_services.asp" device="$device" sort="$sort" />
<AAT:BackButton />
<WebUI:PageBottom />
