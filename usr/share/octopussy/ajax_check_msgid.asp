<%
my $service = $Request->QueryString("service");
my $msgid = $Request->QueryString("msgid");

my $msgid_status = (Octopussy::Service::Msg_ID_unique($service, "$service:$msgid") 
	? "OK" : "NOK");

if (NOT_NULL($Session->{AAT_LOGIN}))
{
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<msgid_status><%= $msgid_status %></msgid_status>
</root>
<%
}
%>
