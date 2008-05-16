<%
my %arg = @_;

my @alerts = ("-ANY-");
push(@alerts, (defined $arg{restricted_alerts}
	? AAT::ARRAY($arg{restricted_alerts}) : Octopussy::Alert::List()));
my @devices = ("-ANY-");
push(@devices, (defined $arg{restricted_devices} 
	? AAT::ARRAY($arg{restricted_devices}) : Octopussy::Device::List()));
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Label value="_ALERT" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Selector name="alert" list=\@alerts selected="$arg{alert}" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_DEVICE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Selector name="device" list=\@devices selected="$arg{device}" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_STATUS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_alert_status" any="1" selected="$arg{status}" />
  </AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_FILTER" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
