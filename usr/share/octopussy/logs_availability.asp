<WebUI:PageTop title="_LOGS_AVAILABILITY" help="" />
<%
my $q = $Request->QueryString();
my ($device, $year, $month, $day, $hour) = 
	($q->{device}, $q->{year}, $q->{month}, $q->{day}, $q->{hour});

if (AAT::NOT_NULL($hour))
{
	%><AAT:Inc file="octo_logs_availability_hour" device="$device" 
  	year="$year" month="$month" day="$day" hour="$hour" /><%
}
elsif (AAT::NOT_NULL($day))
{
	%><AAT:Inc file="octo_logs_availability_day" device="$device" 
		year="$year" month="$month" day="$day" /><%
}
elsif (AAT::NOT_NULL($month))
{
	%><AAT:Inc file="octo_logs_availability_month" device="$device" 
    year="$year" month="$month" /><%
}
%>
<WebUI:PageBottom />
