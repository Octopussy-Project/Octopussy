<%
my $role = $Session->{AAT_ROLE};
my $report_type = $Request->QueryString("report_type");
my $filename = $Request->QueryString("filename");
my $dir_reports = Octopussy::Directory("data_reports");

if ($role =~ /restricted/i)
{
	my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN});
	my @res_reports = AAT::ARRAY($restricts->{report});
	my $in_restriction = ($#res_reports >= 0 ? 0 : 1);
	foreach my $res (@res_reports)
  	{ $in_restriction = 1 if ($report_type eq $res); }
	$Response->Redirect("./restricted_reports_viewer.asp")	
		if (! $in_restriction);
}

if (($filename !~ /\.html$/) && ($filename !~ /\.png$/))
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
else
{
	if ($role =~ /restricted/i)
  	{ %><WebUI:PageTopRestricted title="Report Show" /><% }
  else
  	{ %><WebUI:PageTop title="Report Show" /><% }
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
%><WebUI:PageBottom /><%
}%>
