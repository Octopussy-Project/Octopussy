<WebUI:PageTop title="Statistic Report Edit" />
<%
my $f = $Request->Form();
my $statistic_report = $Request->QueryString("statistic_report");
my $table = $Request->QueryString("table");
my $modify = $f->{modify};

if ((NOT_NULL($modify)) && ($Session->{AAT_ROLE} !~ /ro/i))
{
	if (NULL($f->{old_statistic_report}))
	{
		Octopussy::Statistic_Report::New( 
			{ name => $f->{name}, description => $f->{description},
				table => $f->{table}, 
				datasource1 => $f->{datasource1}, datasource2 => $f->{datasource2},
				datasource3 => $f->{datasource3}, 
				datasources_value => $f->{datasources_value} } );
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", 
			"Statistic Report", $f->{name});
	}
	else
	{
		Octopussy::Statistic_Report::Modify($f->{old_statistic_report},
			{ name => $f->{name}, description => $f->{description},
				table => $f->{table}, 
				datasource1 => $f->{datasource1}, datasource2 => $f->{datasource2},
				datasource3 => $f->{datasource3}, 
				datasources_value => $f->{datasources_value} });
		AAT::Syslog("octo_WebUI", "GENERIC_MODIFIED",
			"Statistic Report", $f->{old_statistic_report});
	}
	$Response->Redirect("./statistic_reports.asp");
}
else
{
%><AAT:Inc file="statistic_report_edition" url="./statistic_report_edit.asp"
	statistic_report="$statistic_report" table="$table" /><%
}
%>
<WebUI:PageBottom />
