<WebUI:PageTop title="Service Message Edition" help="Services" />
<%
my $service = $Request->QueryString("service");
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
my $msgid = $Request->QueryString("msgid");

$Response->Include('INC/octo_service_message_editor.inc', 
	action => "./service_message_modify.asp", 
	service => $service, msgid => $msgid);
%>
<WebUI:PageBottom />
