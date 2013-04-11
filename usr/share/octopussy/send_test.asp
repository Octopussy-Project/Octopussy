<%
if (NOT_NULL($Session->{AAT_LOGIN}))
{
	my $qs = $Request->QueryString();
	my ($subject, $body) = (undef, undef);
	my ($type, $dest) = ($qs->{type}, $qs->{dest});
	my $redirect = $qs->{redirect} || "./contacts.asp";
	$redirect = (($redirect =~ /[a-z_]+\.asp.*/) ? $redirect : "./contacts.asp");
	$subject = $body = "Octopussy " . uc($type) . " Send Test";

	if ($type eq "smtp")
	{
  		AAT::SMTP::Send_Message("Octopussy", { subject => $subject, body => $body, dests => [ $dest ] });
	}
	elsif ($type eq "xmpp")
	{
 		AAT::XMPP::Send_Message("Octopussy", $body, $dest);
	}
	$Response->Redirect($redirect);
}
%>
