<AAT:PageTop />
<%
my @errors = ();
my $f = $Request->Form();

if (NULL($f->{msgid_end}))
	{ push(@errors, "_MSG_MSGID_CANT_BE_NULL"); }
else
{
	my %msg_conf = ( msg_id => "$f->{msgid_begin}:$f->{msgid_end}", 
		loglevel => $f->{loglevel}, taxonomy => $f->{taxonomy}, 
		table => $f->{table}, pattern => $f->{msg_pattern} );
	
	push(@errors, Octopussy::Service::Add_Message($f->{service}, \%msg_conf))
		if ($Session->{AAT_ROLE} !~ /ro/i); 
}
if (scalar(@errors))
{ 
	%><AAT:Box align="C"><%
	foreach my $e (@errors)
	{
		%><AAT:BoxRow><AAT:BoxCol>
		<AAT:Message level="2" msg="$e" />
		</AAT:BoxCol></AAT:BoxRow><%
	}
	%></AAT:Box><% 
}
else
	{ $Response->Redirect("./services.asp?service=" . $f->{service}); }
%>
<AAT:PageBottom />
