<WebUI:PageTop title="Octopussy Report Errors" />
<%
my $file = $Request->QueryString("file");
$Response->Redirect("./services.asp")	
	if ($file !~ /^.+octo_reporter_.+\.err$/);
$Response->Include('INC/octo_report_errors.inc', file => $file);
%>
<WebUI:PageBottom />
