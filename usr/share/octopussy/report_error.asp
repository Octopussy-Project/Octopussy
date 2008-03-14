<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Octopussy Report Errors" />
<%
my $file = $Request->QueryString("file");

$Response->Include('INC/report_errors.inc', file => $file);
%>
<WebUI:PageBottom />
