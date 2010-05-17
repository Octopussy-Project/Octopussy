<%
my %arg = @_;
my ($re_include, $re_include2, $re_include3) =
  ($Session->{re_include}, $Session->{re_include2}, $Session->{re_include3});
my ($re_exclude, $re_exclude2, $re_exclude3) =
  ($Session->{re_exclude}, $Session->{re_exclude2}, $Session->{re_exclude3});

my @devices = ARRAY($arg{devices});
my @services = ARRAY($arg{services});

my @restricted_devices = ARRAY($arg{restricted_devices});
my @restricted_services = ARRAY($arg{restricted_services});
my $unknown = (NOT_NULL($arg{unknown}) ? 1 : undef);
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="C" title="_REAL_TIME_LOGS_VIEWER" icon="buttons/bt_search">
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
      unknown=$unknown multiple="1" size="6" selected=\@devices 
			restricted_devices=\@restricted_devices /></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:Button name="service" /><br>
    <AAT:Label value="_SERVICES" align="R" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
      unknown=$unknown multiple="1" size="6" device=\@restricted_devices 
			selected=\@services restricted_services=\@restricted_services />
		</AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:BoxCol>
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
      size="50" style="color:green" />
  </AAT:BoxCol>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude2" value="$re_exclude2" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_ok" tooltip="_REGEXP_INC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_include3" value="$re_include3"
      size="50" style="color:blue" />
  </AAT:BoxCol>
  <AAT:BoxCol align="R">
  <AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude3" value="$re_exclude3" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="2">
  <AAT:Form_Submit name="logs" value="_GET_LOGS" />
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
