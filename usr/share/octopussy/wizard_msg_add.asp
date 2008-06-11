<AAT:PageTop />
<%
my $return = undef;
my $f = $Request->Form();

if (AAT::NULL($f->{msgid_end}))
	{ $return = "_MSG_MSGID_CANT_BE_NULL"; }
else
{
	my %msg_conf = ( msg_id => "$f->{msgid_begin}:$f->{msgid_end}", 
		loglevel => $f->{loglevel}, taxonomy => $f->{taxonomy}, 
		table => $f->{table}, pattern => $f->{msg_pattern} );
	
	$return = Octopussy::Service::Add_Message($f->{service}, \%msg_conf)
		if ($Session->{AAT_ROLE} !~ /ro/i); 
}
if (defined $return)
{ 
	%><AAT:Message level="2" msg="$return" /><% 
}
else
	{ $Response->Redirect("./services.asp?service=" . $f->{service}); }
%>
<AAT:PageBottom />
