<WebUI:PageTop title="_ALERTS" help="alerts" />
<%
my $f = $Request->Form();
my $alert = Encode::decode_utf8($f->{alert} || $Request->QueryString("alert"));
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("alerts_table_sort") || "name";

if (AAT::NULL($alert))
{
	%><AAT:Inc file="octo_alerts_list" url="./alerts.asp" sort="$sort" /><%
}
else
{
  if ((!-f Octopussy::Alert::Filename($alert)) 
			&& ($Session->{AAT_ROLE} !~ /ro/i))
  {
		my @devices = AAT::ARRAY($f->{device});
  	my @services = AAT::ARRAY($f->{service});
  	my @actions = (AAT::ARRAY($f->{action_mailing}), 
      AAT::ARRAY($f->{action_program}));
  	my @contacts = AAT::ARRAY($f->{contact});

    Octopussy::Alert::New({ name => $alert, 
			description => Encode::decode_utf8($f->{description}), 
			level => $f->{level}, type => "Dynamic", taxonomy => $f->{taxonomy},
			status => ($f->{status} || "Enabled"),
			timeperiod => $f->{timeperiod}, 
			device => \@devices, service => \@services,
			regexp_include => $f->{regexp_include},
			regexp_exclude => $f->{regexp_exclude},
			thresold_time => $f->{thresold_time},
			thresold_duration => $f->{thresold_duration},
			action => \@actions, contact => \@contacts, 
			msgsubject => Encode::decode_utf8($f->{subject}), 
      msgbody => Encode::decode_utf8($f->{body}),
      action_host => Encode::decode_utf8($f->{action_host}),
      action_service => Encode::decode_utf8($f->{action_service})
      });
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Alert", $alert);
  }

  if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /admin/i))
  {
    Octopussy::Alert::Remove($alert);
		AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Alert", $alert);
  }
	$Response->Redirect("./alerts.asp");
}
%>
<WebUI:PageBottom />
