<WebUI:PageTop title="Octopussy Report Errors" />
<%
my $file = $Request->QueryString("file");

$Response->Include('INC/octo_report_errors.inc', file => $file);
%>
<WebUI:PageBottom />
