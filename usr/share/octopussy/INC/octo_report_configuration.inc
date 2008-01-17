<%
my %arg = @_;
my $report = $arg{report};
my $device = $arg{device};
my $service = $arg{service};
my $r = Octopussy::Report::Configuration($report);
my ($devices, $services) = Octopussy::Table::Devices_and_Services_With($r->{table});
my $desc = $r->{description};
my $query = $r->{query};
$query =~ s/(SELECT |FROM |WHERE |GROUP BY |ORDER BY |LIMIT )/<b>$1<\/b>/g;
$query =~ s/FROM/\<br\>FROM/g;

my $taxo = $r->{taxonomy};
my $url_dt = "./reports.asp?report=$report&query=$query";
%>
<AAT:Form action="$arg{url}">
<AAT:Form_Hidden name="report" value="$report" />
<AAT:Box align="center">
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"><AAT:Label value="_REPORT" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$report" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"><AAT:Label value="_DESCRIPTION" style="B" />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$desc" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"><AAT:Label value="_QUERY" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$query" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Button name="device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
    url="./reports.asp?report=$report&device=" 
		list=$devices selected="$device" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Button name="service" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_SERVICE" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_service_dynamic"
    url="./reports.asp?report=$report&device=$device&service=" 
		device="$device" list=$services selected="$service" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%
if (($r->{taxonomy} ne "") && ($r->{taxonomy} ne "-ANY-"))
{ 
	%><AAT:Form_Hidden name="taxonomy" value="$taxo" />
  <AAT:Label value="$taxo" /><%
}
else
 { %><AAT:Inc file="octo_selector_taxonomy" any="1" /><% } %>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="center" cspan="3">
  <AAT:Selector_DateTime_Simple name="dt" start_year="2000" url="$url"
    selected1="$arg{d1}/$arg{m1}/$arg{y1}/$arg{hour1}/$arg{min1}" 
		selected2="$arg{d2}/$arg{m2}/$arg{y2}/$arg{hour2}/$arg{min2}" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><AAT:Inc file="octo_export_mail" width="100%" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><AAT:Export_FTP width="100%" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><AAT:Export_SCP width="100%" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="3" align="C">
	<AAT:Form_Hidden name="submit" value="1" />
	<AAT:Form_Submit value="_LAUNCH_REPORT"	/></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
