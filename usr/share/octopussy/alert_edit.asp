<WebUI:PageTop title="Alert Edit" help="alerts" />
<%
my $f = $Request->Form();

if ((defined $f->{modify}) && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
{
	$Response->Redirect("./alerts.asp")
    	if (! Octopussy::Alert::Valid_Name($f->{name}));

	my @devices = ARRAY($f->{device});
	my @services = ARRAY($f->{service});
  my @actions = (ARRAY($f->{action_mailing}),
      ARRAY($f->{action_program}));
	my @contacts = ARRAY($f->{contact});
  my $body = $f->{body};
	Octopussy::Alert::Modify($f->{old_alert},
		{ name => $f->{name}, 
			description => Encode::decode_utf8($f->{description}), 
			level => $f->{level}, type => "Dynamic", loglevel => $f->{loglevel}, 
      taxonomy => $f->{taxonomy}, timeperiod => $f->{timeperiod},
			status => ($f->{status} || "Enabled"),
			device => \@devices, service => \@services,
			regexp_include => $f->{regexp_include},
			regexp_exclude => $f->{regexp_exclude},
			thresold_time => $f->{thresold_time},
			thresold_duration => $f->{thresold_duration},
			minimum_emit_delay => $f->{minimum_emit_delay},
			action => \@actions, contact => \@contacts, 
			msgsubject => Encode::decode_utf8($f->{subject}), 
      msgbody => Encode::decode_utf8($f->{body}),
      action_host => Encode::decode_utf8($f->{action_host}),
      action_service => Encode::decode_utf8($f->{action_service}),
      action_body => Encode::decode_utf8($f->{action_body}),
      }
		);			
	AAT::Syslog::Message("octo_WebUI", "GENERIC_MODIFIED", "Alert", $f->{old_alert}, $Session->{AAT_LOGIN});
	$Response->Redirect("./alerts.asp");
}
else
{
	my $alert = $Request->QueryString("alert");
	%><AAT:Inc file="octo_alert_edit" alert="$alert" /><%
}
%>
<WebUI:PageBottom />
