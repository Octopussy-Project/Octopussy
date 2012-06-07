<WebUI:PageTop title="Device Services" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
$device = (Octopussy::Device::Valid_Name($device) ? $device : undef);
my $service = $f->{service} || $Request->QueryString("service");
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
$action = $Request->QueryString("action");
my $sort = $Request->QueryString("device_services_table_sort") || "rank";

if (defined $service)
{
	if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
	{ 
    		Octopussy::Device::Remove_Service($device, $service);  
  	}
	elsif ($action eq "show")
		{ $Response->Redirect("./services.asp?service=$service"); }
	elsif (($action =~ /(up|down|top|bottom)/i) 
		&& ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
  	{	 
    		Octopussy::Device::Move_Service($device, $service, $action); 
  	}
  	elsif ((my ($option, $status) = $action =~ /^(compression|statistics)_(disable|enable)$/) 
		&& ($Session->{AAT_ROLE} =~ /(?:admin|rw)/i))
  	{
    	Octopussy::Device::Set_Service_Option($device, $service, 
			$option, $status);
  	}
	elsif ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
		{ Octopussy::Device::Add_Service($device, $service); }
}
%>
<AAT:Inc file="octo_device_services_list" 
	url="./device_services.asp" device="$device" sort="$sort" />
<WebUI:PageBottom />
