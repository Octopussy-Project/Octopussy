<%
my @errors = ();
my $f = $Request->Form();

my %mconf = ( msg_id => "$f->{msgid_begin}:$f->{msgid_end}", 
	loglevel => $f->{loglevel}, rank => $f->{rank}, 
	taxonomy => $f->{taxonomy}, table => $f->{table}, 
	pattern => $f->{msg_pattern} );

push(@errors, Octopussy::Service::Modify_Message($f->{service}, $f->{old_msgid},
	\%mconf))	if ($Session->{AAT_ROLE} !~ /ro/i); 

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
{
	$Response->Redirect("./services.asp?service=$f->{service}");
}
%>
