<WebUI:PageTopRestricted title="Reports Viewer" />
<%
my $role = $Session->{AAT_ROLE};
my $q = $Request->QueryString();
my $url = "./restricted_reports_viewer.asp";
my $url_sort = $url . "?reports_table_sort=";
my $sort = $q->{sort};
my ($category, $report) = ($q->{category}, $q->{report});
my ($month, $year) = ($q->{month}, $q->{year});
my ($action, $filename) = ($q->{action}, $q->{filename});

if ((NULL($report)) && (NULL($category)))
	{ %><AAT:Inc file="octo_viewer_reportcategory_list" url="$url" /><% }
elsif (NULL($report))
	{ %><AAT:Inc file="octo_viewer_reporttype_list" 
		category="$category" url="$url" /><% }
else
{
	if ((NOT_NULL($month)) && (NOT_NULL($year)) && ($role !~ /ro/i))
		{ Octopussy::Data_Report::Remove_Month($report, $year, $month); }
	elsif (($action eq "remove") && ($role !~ /ro/i))
		{ Octopussy::Data_Report::Remove($report, $filename); }
%><AAT:Inc file="octo_viewer_report_list" report="$report" 
	url="${url}?report=$report" /><%
}
%>
<WebUI:PageBottom />
