<%
my %arg = @_;
my $url = $arg{url};
my @serv_confs = Octopussy::Service::Configurations();
my $serv_updates = Octopussy::Web_Updates("Services");
%>
<AAT:Box icon="buttons/bt_service" title="_SERVICES_UPDATES" align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_SERVICE_NAME" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_VERSION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>	
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
  <AAT:Form action="$url">
<%
my $has_updates = 0;
foreach my $sc (@serv_confs)
{
  if ($serv_updates->{$sc->{name}} > $sc->{version})
  {
		my ($sc_name, $sc_desc, $diff_version) = ($sc->{name}, $sc->{description},
      "$serv_updates->{$sc->{name}} > $sc->{version}");
    $has_updates = 1;
	%><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$sc_name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$sc_desc" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$diff_version" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="_SHOW_DIFF" 
		link_new="./updater_diff.asp?service=$sc_name"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:CheckBox name="service_update_$sc_name" /></AAT:BoxCol>
	</AAT:BoxRow><%
  }
}
foreach my $k (sort keys %{$serv_updates})
{
  my $match = 0;
  foreach my $sc (@serv_confs)
    { $match = 1  if ($sc->{name} eq $k); }
  if (!$match)
  {
		$has_updates = 1;
		%><AAT:BoxRow><AAT:BoxCol cspan="2"><AAT:Label value="$k" /></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:Label value="_NEW_SERVICE" color="red"/></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:CheckBox name="service_update_$k" selected="1"/></AAT:BoxCol>
    </AAT:BoxRow><%
  }
}
if ($has_updates)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol align="C" cspan="5">
  <AAT:Form_Submit value="_MSG_UPDATE_SELECTED_SERVICES" />
  </AAT:BoxCol></AAT:BoxRow><%	
}
else
{
	%><AAT:BoxRow><AAT:BoxCol align="C" cspan="5">
  <AAT:Label value="_MSG_NO_UPDATES_AVAILABLE" style="B"/>
	</AAT:BoxCol></AAT:BoxRow><%
}
%></AAT:Form>
</AAT:Box>
