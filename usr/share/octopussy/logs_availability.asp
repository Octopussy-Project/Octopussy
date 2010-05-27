<WebUI:PageTop title="_LOGS_AVAILABILITY" help="" />
<%
my $q = $Request->Params();
my ($device, $year, $month, $day, $hour, $period) = 
	($q->{device}, $q->{year}, $q->{month}, $q->{day}, $q->{hour}, $q->{period});

if (NOT_NULL($period))
{
	my ($y, $m, $d, $h) = AAT::Utils::Now();
	if ($period =~ /^hour$/)
		{ ($year, $month, $day, $hour) = ($y, $m, $d, $h); }
	elsif ($period =~ /^day$/)
		{ ($year, $month, $day) = ($y, $m, $d); }
	elsif ($period =~ /^month$/)
		{ ($year, $month) = ($y, $m); }
	else
		{ $year = $y; }
}

my @devices = Octopussy::Device::List();
my @list = ( 
	{ label => "_HOUR", value => "hour" }, 
	{ label => "_DAY", value => "day" },
	{ label => "_MONTH", value => "month" },
	{ label => "_YEAR", value => "year" } );
%>
<AAT:Form action="logs_availability.asp">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:IMG name="buttons/bt_device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector name="device" list=\@devices selected="$device" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:IMG name="buttons/bt_scheduler" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector name="period" list=\@list selected="$period" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="Check Availability for this device" />
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
if (NOT_NULL($device))
{
	if (NOT_NULL($hour))
	{
	%><AAT:Inc file="octo_logs_availability_hour" device="$device" 
  	year="$year" month="$month" day="$day" hour="$hour" /><%	
	}
	elsif (NOT_NULL($day))
	{
	%><AAT:Inc file="octo_logs_availability_day" device="$device" 
		year="$year" month="$month" day="$day" /><%
	}
	elsif (NOT_NULL($month))
	{
	%><AAT:Inc file="octo_logs_availability_month" device="$device" 
    year="$year" month="$month" /><%
	}
	elsif (NOT_NULL($year))
	{
	%><AAT:Inc file="octo_logs_availability_year" device="$device" 
   	year="$year" /><%
	}
}
%>
<WebUI:PageBottom />
