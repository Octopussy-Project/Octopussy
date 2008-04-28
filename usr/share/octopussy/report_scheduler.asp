<WebUI:PageTop title="Scheduler" help="#scheduler_page" />
<%
my $f = $Request->Form();
my $name = $f->{name} || $Request->QueryString("name");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("schedules_table_sort");

my @dow = ();
my @dom = ();
my @months = ();
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
		foreach my $k (keys %{$f})
		{
		  push(@dow, $1)  if ($k =~ /^dow_(.+)/);
			push(@dom, $1)  if ($k =~ /^dom_(.+)/);
			push(@months, $1)  if ($k =~ /^month_(.+)/);
		}
		my $recipients = "";
  	foreach my $r ($f->{mail_recipients})
  	{
    	my $c = Octopussy::Contact::Configuration($r);
    	$recipients .= "$c->{email},"
  	}
  	my %mail_conf = (recipients => $recipients, subject => $f->{mail_subject});
  	my %ftp_conf = (host => $f->{ftp_host}, dir => $f->{ftp_dir},
    	user => $f->{ftp_user}, pwd => $f->{ftp_pwd});
  	my %scp_conf = (host => $f->{scp_host}, dir => $f->{scp_dir}, 
			user => $f->{scp_user});

		if (Octopussy::Schedule::Period_Check($f->{Day1}, $f->{Hour1}, 
			$f->{Day2}, $f->{Hour2}))
		{
			my $error = Octopussy::Schedule::Add({ title => $name, 
				start_time => "$f->{start_hour}:$f->{start_min}",
				start_day => $f->{Day1}, start_hour => $f->{Hour1},
				finish_day => $f->{Day2}, finish_hour => $f->{Hour2},
				dayofweek => \@dow, dayofmonth => \@dom, month => \@months, 
				device => $f->{device}, service => $f->{service},
				taxonomy => $f->{taxonomy}, 
				mail => \%mail_conf, ftp => \%ftp_conf, scp => \%scp_conf, 
				report => $f->{report}});
			if (AAT::NOT_NULL($error))
			{
			%><AAT:Message level="2" msg="$error" /><%
			}
			else
				{ AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Schedule", $name); }
		}
		else
		{
		%><AAT:Message level="2" msg="_MSG_INVALID_SCHEDULE_PERIOD" /><%
		}
	}
}
%>
<AAT:Inc file="octo_report_schedules_list" 
	url="./report_scheduler.asp" sort="$sort" />
<% $Response->Include("INC/octo_report_scheduler.inc", form => $f, 
	url => "./report_scheduler.asp")	if ($Session->{AAT_ROLE} !~ /ro/i) %>
<WebUI:PageBottom />
