<WebUI:PageTop title="Report" help="#reports_page" />
<%
my $url = "./reports.asp";

my $f = $Request->Form();
my $report = $f->{report} || $Request->QueryString("report");
my $category = $f->{category} || $Request->QueryString("category");
my $device = $Request->QueryString("device") || $f->{device};
my $service = $Request->QueryString("service") || $f->{service};
my $taxonomy = $Request->QueryString("taxonomy") || $f->{taxonomy};
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("reports_table_sort") || "name";

my $d1 = $Session->{"dt1_day"}; 
my $m1 = $Session->{"dt1_month"};
my $y1 = $Session->{"dt1_year"};
my ($h1, $min1) = ($Session->{"dt1_hour"}, $Session->{"dt1_min"});
my $d2 = $Session->{"dt2_day"};
my $m2 = $Session->{"dt2_month"};
my $y2 = $Session->{"dt2_year"};
my ($h2, $min2) = ($Session->{"dt2_hour"}, $Session->{"dt2_min"});

if ((defined $action) && ($action eq "remove") 
		&& ($Session->{AAT_ROLE} !~ /ro/i))
{
	Octopussy::Report::Remove($report);
	AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Report", $report);
 	$Response->Redirect("./reports.asp");	
}
elsif (!defined $report)
{
	if (!defined $category)
	{
	%><AAT:Inc file="octo_report_categories_list" url="$url" sort="$sort" /><%
	}
	else
	{
	%><AAT:Inc file="octo_reports_list" url="$url" 
			category="$category" sort="$sort" /><%
	}
}
elsif (!defined $f->{submit})
{
%><AAT:Inc file="octo_report_configuration" report="$report"
	url="./reports.asp?device=$device&service=$service" 
	device="$device" service="$service" 
	d1="$d1" m1="$m1" y1="$y1" h1="$h1" min1="$min1" 
	d2="$d2" m2="$m2" y2="$y2" h2="$h2" min2="$min2"/><%
}
else
{
	my $r = Octopussy::Report::Configuration($report);
	my $start = "$y1$m1$d1$h1$min1";
	my $finish = "$y2$m2$d2$h2$min2";
	my $recipients = "";
	foreach my $rec ($f->{mail_recipients})
	{
		my $c = Octopussy::Contact::Configuration($rec);
		$recipients .= "$c->{email},"
	}
	$recipients =~ s/,$//;

	my %mail_conf = (recipients => $recipients, subject => $f->{mail_subject});
	my %ftp_conf = (host => $f->{ftp_host}, dir => $f->{ftp_dir},	
		user => $f->{ftp_user}, pwd => $f->{ftp_pwd} );
	my %scp_conf = (host => $f->{scp_host}, dir => $f->{scp_dir},
    user => $f->{scp_user} );

	my $cmd = Octopussy::Report::CmdLine($device, $service, $taxonomy, $r, 
		$start, $finish, \%mail_conf, \%ftp_conf, \%scp_conf, 
		$Session->{AAT_LANGUAGE});
 	$Response->Redirect("./report_in_progress.asp?cmd=" 
		. $Server->URLEncode($cmd));
}
%>
<WebUI:PageBottom />
