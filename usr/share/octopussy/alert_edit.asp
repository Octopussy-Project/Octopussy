<WebUI:PageTop title="Alert Edit" help="alerts" />
<%
my $alert = $Request->QueryString("alert");
my $f = $Request->Form();

if ((defined $f->{modify}) && ($Session->{AAT_ROLE} !~ /ro/i))
{
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
	%><AAT:Inc file="octo_alert_edit" alert="$alert" /><%
}
%>
<WebUI:PageBottom />
