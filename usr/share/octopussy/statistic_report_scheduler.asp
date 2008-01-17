<WebUI:PageTop title="Scheduler" help="#scheduler_page" />
<%
my $url = "statistic_report_scheduler.asp";
my $f = $Request->Form();
my $name = $f->{name} || $Request->QueryString("name");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("schedules_table_sort");

my @devices = ();
my @services = ();

if ((defined $name) && ($Session->{AAT_ROLE} !~ /ro/i))
{
	if ($action =~ /remove/)
	{
		Octopussy::Schedule::Remove($name);
		AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Schedule", $name);
		$Response->Redirect("./scheduler.asp");
	}
	else
	{
		my $recipients = "";
  	foreach my $r ($f->{mail_recipients})
  	{
    	my $c = Octopussy::Contact::Configuration($r);
    	$recipients .= "$c->{email},"
  	}
  	my %mail_conf = (
    	recipients => $recipients, subject => $f->{mail_subject} );
  	my %ftp_conf = (
    	host => $f->{ftp_host}, dir => $f->{ftp_dir},
    	user => $f->{ftp_user}, pwd => $f->{ftp_pwd} );
  	my %scp_conf = (host => $f->{scp_host},
    	dir => $f->{scp_dir}, user => $f->{scp_user} );
		
		Octopussy::Schedule::Add({ title => $name, 
			start_time => "$f->{start_hour}:$f->{start_min}",
			device => $f->{device}, service => $f->{service},
			taxonomy => $f->{taxonomy}, 
			mail => \%mail_conf, ftp => \%ftp_conf, scp => \%scp_conf,
			report => $f->{report}});
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Schedule", $name);
	}
}
%>
<AAT:Inc file="statistic_report_schedules_list" url="$url" sort="$sort" />
<% 
$Response->Include("INC/statistic_report_scheduler.inc", 
	form => $f, url => $url) if ($Session->{AAT_ROLE} !~ /ro/i) 
%>
<WebUI:PageBottom />
