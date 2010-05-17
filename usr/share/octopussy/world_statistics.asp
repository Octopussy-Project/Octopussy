<WebUI:PageTop title="_WORLD_STATISTICS" />
<%
my $url = Octopussy::Parameter("url_world_stats_show");
my $f = $Request->Form();
if (defined $f->{submit})
{
  my $id = Octopussy::World_Stats::ID();
  my $status = (NOT_NULL($f->{send_data}) ? "enabled" : "disabled" );
  Octopussy::World_Stats::Modify( 
    { id => $id, country => $f->{country}, status => $status } );
  AAT::Syslog("octo_WebUI", "WORLD_STATS_STATUS_CHANGED", $status);
}
my $conf = Octopussy::World_Stats::Configuration();
my $c_country = $conf->{country};
my $c_selected = ($conf->{status} eq "enabled" ? 1 : 0);

my $msg = "Octopussy can send statistics data to 8pussy.org official website.<br>
Data is sent only once a day.<br> 
It's only anonymous data:
<li>CPU</li>
<li>memory</li>
<li>country code</li>
<li>number of devices</li>
<li>number of services</li>
<li>number of logs handled every hour</li>";
%>
<AAT:Form action="./world_statistics.asp">
<AAT:Box align="C" icon="buttons/bt_web" title="_WORLD_STATISTICS">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Picture file="IMG/octopussy.gif" width="200"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$msg" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
  <AAT:CheckBox name="send_data" selected="$c_selected" />
  </AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_MSG_OK_TO_SEND_DATA_TO_8PUSSY" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Entry name="country" size="2" value="$c_country" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_COUNTRY" /> (FR/UK/US...)</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="2">
  <AAT:Form_Submit name="submit" value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:IMG name="buttons/bt_web" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="Go to 8pussy.org World Statistics" link="$url" />
  </AAT:BoxCol>
  <AAT:BoxCol><AAT:IMG name="buttons/bt_web" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
