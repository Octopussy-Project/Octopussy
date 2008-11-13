<%
my %arg = @_;
my $report = $arg{report};
my $device = $arg{device};
my $service = $arg{service};
my $r = Octopussy::Report::Configuration($report);
my ($devicegroups, $devices, $services) = 
	Octopussy::Table::Devices_and_Services_With($r->{table});
my @res_devs = ();
foreach my $dg (AAT::ARRAY($devicegroups))
	{ push(@res_devs, "group $dg"); }
push(@res_devs, @{$devices});
my $desc = $r->{description};
my $query = $r->{query};
$query =~ s/(SELECT |FROM |WHERE |GROUP BY |ORDER BY |LIMIT )/<b>$1<\/b>/g;
$query =~ s/FROM/\<br\>FROM/g;
my $loglevel = $r->{loglevel};
my $taxo = $r->{taxonomy};
my $url_dt = "./reports.asp?report=$report&query=$query";
%>
<AAT:Form action="$arg{url}">
<AAT:Form_Hidden name="report" value="$report" />
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:IMG name="generic_report" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Box width="100%">
	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Label value="_REPORT" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$report" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Label value="$desc" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol><AAT:Label value="_QUERY" style="B" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Label value="$query" /></AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Box align="R">
  <AAT:BoxRow>
    <AAT:BoxCol align="C">
    <AAT:Button name="device" /><br>
    <AAT:Label value="_DEVICE" align="R" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
			url="./reports.asp?report=$report&device=" multiple="1" size="5" 
			selected="$device" restricted_devices=\@res_devs /></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:Button name="service" /><br>
    <AAT:Label value="_SERVICE" align="R" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
			url="./reports.asp?report=$report&device=$device&service="
      multiple="1" size="5" device=\@res_devs
      selected=$service restricted_services=$services />
    </AAT:BoxCol>
  </AAT:BoxRow>
  <AAT:BoxRow>
		<AAT:BoxCol align="R">
		<AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><%
		if (($loglevel ne "") && ($loglevel ne "-ANY-"))
    {
    %><AAT:Form_Hidden name="loglevel" value="$loglevel" />
    <AAT:Label value="$loglevel" /><%
    }
    else
      { %><AAT:Inc file="octo_selector_loglevel_dynamic" any="1" /><% } %>
		</AAT:BoxCol>
    <AAT:BoxCol align="R">
    <AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><%
    if (($taxo ne "") && ($taxo ne "-ANY-"))
    {
    %><AAT:Form_Hidden name="taxonomy" value="$taxo" />
    <AAT:Label value="$taxo" /><%
    }
    else
      { %><AAT:Inc file="octo_selector_taxonomy_dynamic" any="1" /><% } %>
    </AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_DateTime_Simple name="dt" start_year="2000" url="$url"
    selected1="$arg{d1}/$arg{m1}/$arg{y1}/$arg{hour1}/$arg{min1}"
    selected2="$arg{d2}/$arg{m2}/$arg{y2}/$arg{hour2}/$arg{min2}" />
	</AAT:BoxCol>
</AAT:BoxRow>
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
