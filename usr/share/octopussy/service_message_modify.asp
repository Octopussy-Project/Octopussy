<%
my $f = $Request->Form();

my %mconf = ( msg_id => "$f->{msgid_begin}:$f->{msgid_end}", 
	loglevel => $f->{loglevel}, rank => $f->{rank}, 
	taxonomy => $f->{taxonomy}, table => $f->{table}, 
	pattern => $f->{msg_pattern} );

my $return = Octopussy::Service::Modify_Message($f->{service}, $f->{old_msgid},
	\%mconf)	if ($Session->{AAT_ROLE} !~ /ro/i); 
if (defined $return)
{
%><%= $return %><%
}
else
{
	$Response->Redirect("./services.asp?service=$f->{service}");
}
%>
