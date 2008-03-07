<WebUI:PageTop title="Alert" help="alerts" />
<%
my $f = $Request->Form();
my $alert = $f->{alert} || $Request->QueryString("alert");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("alerts_table_sort");

if (!defined $alert)
{
	%><AAT:Inc file="alerts_list" url="./alerts.asp" sort="$sort" /><%
}
else
{
  if ((!-f Octopussy::Alert::Filename($alert)) 
			&& ($Session->{AAT_ROLE} !~ /ro/i))
  {
		my @devices = AAT::ARRAY($f->{device});
  	my @services = AAT::ARRAY($f->{service});
  	my @actions = AAT::ARRAY($f->{action});
  	my @contacts = AAT::ARRAY($f->{contact});

    Octopussy::Alert::New({ name => $alert, 
			description => $f->{description}, 
			level => $f->{level}, type => "Dynamic", taxonomy => $f->{taxonomy},
			status => ($f->{status} || "Enabled"),
			timeperiod => $f->{timeperiod}, 
			device => \@devices, service => \@services,
			regexp_include => $f->{regexp_include},
			regexp_exclude => $f->{regexp_exclude},
			thresold_time => $f->{thresold_time},
			thresold_duration => $f->{thresold_duration},
			action => \@actions, contact => \@contacts, 
			msgsubject => $f->{subject}, msgbody => $f->{body} });
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Alert", $alert);
		print "Body: $f->{body}";
		#$Response->Redirect("./alerts.asp");
  }

  if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /admin/i))
  {
    Octopussy::Alert::Remove($alert);
		AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Alert", $alert);
   	$Response->Redirect("./alerts.asp");
  }
  #else
  #{
  #  $Response->Redirect("./alert_configuration.asp?alert=$alert");
  #}
}
%>
<WebUI:PageBottom />
