<%
my $role = $Session->{AAT_ROLE};
my $report_type = $Request->QueryString("report_type");
my $filename = $Request->QueryString("filename");
my $dir_reports = Octopussy::FS::Directory("data_reports");

if ((NOT_NULL($Session->{AAT_LOGIN})) && ($role =~ /^restricted$/i))
{
	my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN}, $Session->{AAT_USER_TYPE});
	my @res_reports = ARRAY($restricts->{report});
	my $in_restriction = (scalar(@res_reports) > 0 ? 0 : 1);
	foreach my $res (@res_reports)
  		{ $in_restriction = 1 if ($report_type eq $res); }
	$Response->Redirect("./restricted_reports_viewer.asp")	
		if (! $in_restriction);
}

if ((NOT_NULL($Session->{AAT_LOGIN})) && ($filename =~ /\.json$/))
{
  	$Session->{ofc_file} = "$dir_reports/$report_type/$filename";
  	%><WebUI:PageTop title="Report Show" ofc="report_ofc.asp" />
  	<AAT:Box>
  	<AAT:BoxRow><AAT:BoxCol>
  	<div id="open_flash_chart"></div>
  	</AAT:BoxCol></AAT:BoxRow>
  	</AAT:Box>
  	<WebUI:PageBottom /><% 
}
elsif ((NOT_NULL($Session->{AAT_LOGIN})) 
	&& (($filename !~ /\.html$/) && ($filename !~ /\.png$/)))
{
	my $ext = $1	if ($filename =~ /\.(\w+)$/);	
	$Response->{ContentType} = "text/$ext";
  	$Response->AddHeader('Content-Disposition', "filename=\"$filename\"");
  	if (defined open(FILE, "< $dir_reports/$report_type/$filename"))
	{
  		while (<FILE>)
    		{ print $_; }
  		close(FILE);
	}
  	$Response->End();
}
elsif (NOT_NULL($Session->{AAT_LOGIN}))
{
	if ($role =~ /restricted/i)
  		{ %><WebUI:PageTopRestricted title="Report Show" /><% }
  	else
  		{ %><WebUI:PageTop title="Report Show" /><% }
	if (-f "$dir_reports/$report_type/$filename")
	{
		if ($filename =~ /\.html$/)
		{
			if (defined open(FILE, "< $dir_reports/$report_type/$filename"))
			{
				while (<FILE>)
					{ print $_; }
				close(FILE);
			}
		}
		else
		{
		%><div align="center">
		<img src="./img_report.asp?file=<%= "$dir_reports/$report_type/$filename" %>">
		</div><%
		}
	}
	else
	{
	%><AAT:Message level="1" msg="_REPORT_FILE_DOESNT_EXIST" /><%
	}
%><WebUI:PageBottom /><%
}%>
