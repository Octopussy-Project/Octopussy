<WebUI:PageTop title="_ALERTS" help="alerts" />
<%
my $f = $Request->Form();
my $alert = Encode::decode_utf8($f->{alert} || $Request->QueryString("alert"));
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("alerts_table_sort") || "name";

if (NULL($alert))
{
	%><AAT:Inc file="octo_alerts_list" url="./alerts.asp" sort="$sort" /><%
}
else
{
  	if ((!-f Octopussy::Alert::Filename($alert)) 
			&& ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
	{
		my @devices = ARRAY($f->{device});
  		my @services = ARRAY($f->{service});
  		my @actions = (ARRAY($f->{action_mailing}), ARRAY($f->{action_program}));
  		my @contacts = ARRAY($f->{contact});

    	my $alert_file = Octopussy::Alert::New({ name => $alert, 
			description => Encode::decode_utf8($f->{description}), 
			level => $f->{level}, type => "Dynamic", loglevel => $f->{loglevel},
      		taxonomy => $f->{taxonomy}, timeperiod => $f->{timeperiod},
			status => ($f->{status} || "Enabled"),
			device => \@devices, service => \@services,
			regexp_include => $f->{regexp_include},
			regexp_exclude => $f->{regexp_exclude},
			thresold_time => $f->{thresold_time},
			thresold_duration => $f->{thresold_duration},
			minimal_emit_delay => $f->{minimal_emit_delay},
			action => \@actions, contact => \@contacts, 
			msgsubject => Encode::decode_utf8($f->{subject}), 
      		msgbody => Encode::decode_utf8($f->{body}),
      		action_host => Encode::decode_utf8($f->{action_host}),
      		action_service => Encode::decode_utf8($f->{action_service}),
      		action_body => Encode::decode_utf8($f->{action_body}),
      	});
      	if (defined $alert_file)
      	{
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Alert", $alert, $Session->{AAT_LOGIN});
		}
		else
		{
			$Session->{AAT_MSG_ERROR} = "Unable to create Alert '$f->{alert}'";
		}
  	}

  	if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
  	{
    	Octopussy::Alert::Remove($alert);
		AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Alert", $alert, $Session->{AAT_LOGIN});
  	}
	$Response->Redirect("./alerts.asp");
}
%>
<WebUI:PageBottom />
