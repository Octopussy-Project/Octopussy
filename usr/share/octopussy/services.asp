<WebUI:PageTop title="_SERVICES" help="services" />
<%
my $f = $Request->Form();
my $service = $f->{service} || $Request->QueryString("service");
my $action = $Request->QueryString("action");
my $msgid = $Request->QueryString("msgid");
my $sort = $Request->QueryString("services_table_sort");
my $msg_sort = $Request->QueryString("service_messages_table_sort");
$service =~ s/ /_/g;

if (NULL($service))
{
	%><AAT:Inc file="octo_services_list" url="./services.asp" sort="$sort" /><%
}
else
{
	if ((!-f Octopussy::Service::Filename($service))
		&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		if (($service !~ /^Incoming/i) && ($service !~ /^Unknown/i))
		{
  		Octopussy::Service::New({ name => $service, 
				description => $f->{description}, website => $f->{website} });
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Service", $service);
		}
		$Response->Redirect("./services.asp");
 	}

	if (($action eq "remove") && ($Session->{AAT_ROLE} !~ /ro/i))
 	{
		if (defined $msgid)
		{
			Octopussy::Service::Remove_Message($service, $msgid);
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Message", $msgid);
		}
		else
		{
			Octopussy::Service::Remove($service);
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Service", $service);
			$Response->Redirect("./services.asp");
		}
	}
	elsif ((($action eq "up") || ($action eq "down")
		|| ($action eq "top") || ($action eq "bottom"))
		&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Service::Move_Message($service, $msgid, $action);			
		AAT::Syslog("octo_WebUI", "MESSAGE_MOVED_IN_SERVICE", 
			$msgid, $action, $service);
	}
	%><AAT:Inc file="octo_service_messages_list" url="./services.asp"
			service="$service" sort="$msg_sort" /><%
}
%>
<WebUI:PageBottom />
