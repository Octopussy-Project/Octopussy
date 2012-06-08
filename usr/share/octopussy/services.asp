<WebUI:PageTop title="_SERVICES" help="services" />
<%
my $f = $Request->Form();
my $service = $f->{service} || $Request->QueryString("service");
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
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
  		my $svc = Octopussy::Service::New({ name => $service, 
			description => $f->{description}, website => $f->{website} });
		if (defined $svc)
		{
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Service", $service, $Session->{AAT_LOGIN});
		}
		else
		{
			$Session->{AAT_MSG_ERROR} = "Unable to create Service '$service'";
		}
		$Response->Redirect("./services.asp");
 	}

	if (($action eq "remove") && ($Session->{AAT_ROLE} !~ /ro/i))
 	{
		if (defined $msgid)
		{
			Octopussy::Service::Remove_Message($service, $msgid);
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Message", $msgid, $Session->{AAT_LOGIN});
		}
		else
		{
			Octopussy::Service::Remove($service);
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Service", $service, $Session->{AAT_LOGIN});
			$Response->Redirect("./services.asp");
		}
	}
	elsif ((($action eq "up") || ($action eq "down")
		|| ($action eq "top") || ($action eq "bottom"))
		&& ($Session->{AAT_ROLE} !~ /ro/i))
	{
		Octopussy::Service::Move_Message($service, $msgid, $action);			
		AAT::Syslog::Message("octo_WebUI", "MESSAGE_MOVED_IN_SERVICE", $msgid, $action, $service, $Session->{AAT_LOGIN});
	}
	%><AAT:Inc file="octo_service_messages_list" url="./services.asp"
			service="$service" sort="$msg_sort" /><%
}
%>
<WebUI:PageBottom />
