<%
my $action = $Request->QueryString("action");
my $s_report = $Request->QueryString("statistic_report");
if ((defined $action) && ($action eq "remove") 
		&& ($Session->{AAT_ROLE} !~ /ro/i))
{
  Octopussy::Statistic_Report::Remove($s_report);
	AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Statistic Report", $s_report);
  $Response->Redirect("./statistic_reports.asp");
}
%>
<WebUI:PageTop title="_STATISTIC_REPORTS" />
<AAT:Inc file="statistic_reports_list" url="./statistic_reports.asp" />
<%
my @table = ( [ 
	{ label => "Create New Statistic Report", 
		link => "./statistic_report_edit.asp" } ] );
$Response->Include('INC/box.inc', elements => \@table);
%>
<WebUI:PageBottom />
