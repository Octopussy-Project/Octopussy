<%
my %arg = @_;
my $dt = $Session->{dt};
my ($d1, $m1, $y1, $hour1, $min1) =
  ($Session->{dt1_day}, $Session->{dt1_month}, $Session->{dt1_year},
  $Session->{dt1_hour}, $Session->{dt1_min});
my ($d2, $m2, $y2, $hour2, $min2) =
  ($Session->{dt2_day}, $Session->{dt2_month}, $Session->{dt2_year},
  $Session->{dt2_hour}, $Session->{dt2_min});
my ($re_include, $re_include2) =
  ($Session->{re_include}, $Session->{re_include2});
my ($re_exclude, $re_exclude2) =
  ($Session->{re_exclude}, $Session->{re_exclude2});

my @devices = AAT::ARRAY($Session->{device});
my @services = AAT::ARRAY($Session->{service});

my @restricted_devices = AAT::ARRAY($arg{restricted_devices});
my @restricted_services = AAT::ARRAY($arg{restricted_services});
%>
<AAT:Form action="$arg{session}">
<AAT:Box align="C" title="_LOGS_VIEWER" icon="buttons/bt_search">
<AAT:BoxRow>
  <AAT:BoxCol cspan="2">
  <%= $Response->Include("INC/octo_box_search_template.inc") %>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Box align="C">
  <AAT:BoxRow>
    <AAT:BoxCol align="C">
    <AAT:Button name="device" /><br>
    <AAT:Label value="_DEVICES" align="R" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
      unknown="1" multiple="1" size="6" selected=\@devices /></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:Button name="service" /><br>
    <AAT:Label value="_SERVICES" align="R" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
      unknown="1" multiple="1" size="6" device=\@devices selected=\@services
      restricted_services=\@restricted_services /></AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Selector_DateTime_Simple name="dt" start_year="2000" url="$url"
    selected="$dt"
    selected1="$d1/$m1/$y1/$hour1/$min1" selected2="$d2/$m2/$y2/$hour2/$min2" />  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2">
  <AAT:Box align="C">
  <AAT:BoxRow>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_ok" tooltip="_REGEXP_INC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_include" value="$re_include"
      size="50" style="color:red" />
  </AAT:BoxCol>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude" value="$re_exclude" size="50" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_ok" tooltip="_REGEXP_INC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_include2" value="$re_include2"
      size="50" style="color:blue" />
  </AAT:BoxCol>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude2" value="$re_exclude2" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="2">
  <AAT:Form_Submit name="logs" value="_GET_LOGS" />
  <AAT:Form_Submit name="file" value="_DOWNLOAD_FILE" />
  <AAT:Form_Submit name="csv" value="_DOWNLOAD_CSV_FILE" />
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
