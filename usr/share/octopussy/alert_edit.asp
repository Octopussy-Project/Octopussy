<WebUI:PageTop title="Alert Edit" help="alerts" />
<%
my $alert = $Request->QueryString("alert");
my $f = $Request->Form();

if ((defined $f->{modify}) && ($Session->{AAT_ROLE} !~ /ro/i))
{
	my @devices = AAT::ARRAY($f->{device});
	my @services = AAT::ARRAY($f->{service});
	my @actions = AAT::ARRAY($f->{action});
	my @contacts = AAT::ARRAY($f->{contact});

	Octopussy::Alert::Modify($f->{old_alert},
		{ name => $f->{name}, description => $f->{description},
      level => $f->{level}, type => "Dynamic", taxonomy => $f->{taxonomy},
      status => $f->{status}, timeperiod => $f->{timeperiod},
			regexp_include => $f->{regexp_include},
      regexp_exclude => $f->{regexp_exclude},
			thresold_time => $f->{thresold_time},
			thresold_duration => $f->{thresold_duration},
      device => \@devices, service => \@services, action => \@actions,
      contact => \@contacts, msgsubject => $f->{subject}, msgbody => $f->{body}
			});			
	AAT::Syslog("octo_WebUI", "GENERIC_MODIFIED", "Alert", $f->{old_alert});
	$Response->Redirect("./alerts.asp");
}
else
{
	%><AAT:Inc file="alert_edit" alert="$alert" /><%
}
%>
<WebUI:PageBottom />
