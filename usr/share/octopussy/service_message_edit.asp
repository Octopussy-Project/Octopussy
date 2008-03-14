<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Service Message Edition" help="Services" />
<%
my $service = $Request->QueryString("service");
my $msgid = $Request->QueryString("msgid");

$Response->Include('INC/octo_service_message_editor.inc', 
	action => "./service_message_modify.asp", 
	service => $service, msgid => $msgid);
%>
<WebUI:PageBottom />
