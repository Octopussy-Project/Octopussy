<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTopRestricted title="Reports Viewer" />
<%
my $role = $Session->{AAT_ROLE};
my $url = "./restricted_reports_viewer.asp";
my $sort = $Request->QueryString("sort");
my $url_sort = $url . "?reports_table_sort=";
my $category = $Request->QueryString("category");
my $report = $Request->QueryString("report");
my $month = $Request->QueryString("month");
my $year = $Request->QueryString("year");
my $action = $Request->QueryString("action");
my $filename = $Request->QueryString("filename");

if ((!defined $report) && (!defined $category))
{
%><AAT:Inc file="octo_viewer_reportcategory_list" url="$url" /><%
}
elsif (!defined $report)
{
%><AAT:Inc file="octo_viewer_reporttype_list" 
	category="$category" url="$url" /><%
}
else
{
	if ((defined $month) && (defined $year) && ($role !~ /ro/i))
	{
		Octopussy::Data_Report::Remove_Month($report, $year, $month)
	}
	elsif (($action eq "remove") && ($role !~ /ro/i))
	{
		Octopussy::Data_Report::Remove($report, $filename);
	}
%><AAT:Inc file="octo_viewer_report_list" report="$report" 
	url="${url}?report=$report" /><%
}
%>
<WebUI:PageBottom />
