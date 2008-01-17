<%
my $nb_alerts_max = Octopussy::Parameter("max_alerts");
my @alerts = Octopussy::Alert::Tracker("", "", "Opened", 
"", $nb_alerts_max);
my $nb_alerts = $#alerts+1;
my $alerts_color = (($#alerts >= 0) ? "red" : "green");
my $nb_unknown = 0;
foreach my $conf (Octopussy::Device::Configurations())
	{ $nb_unknown += Octopussy::Logs::Unknown_Number($conf->{name}); }
my $unknown_color = (($nb_unknown > 0) ? "red" : "green");

if (($#alerts >= 0) || ($nb_unknown >0))
{
%>
<AAT:Box align="center">
  <AAT:BoxRow>
		<AAT:BoxCol align="R">
			<AAT:Button name="alert" link="./alerts_viewer.asp" />
		</AAT:BoxCol>
		<AAT:BoxCol>
			<AAT:Label value="$nb_alerts " style="B" color="$alerts_color" />
      <AAT:Label value="_ALERTS" style="B" color="$alerts_color" />
    </AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol align="R">
      <AAT:Button name="wizard" link="./wizard.asp" />
    </AAT:BoxCol>
    <AAT:BoxCol>
			<AAT:Label value="$nb_unknown " style="B" color="$unknown_color" />
      <AAT:Label value="_UNKNOWN_MSGS" style="B" color="$unknown_color" />
    </AAT:BoxCol>
  </AAT:BoxRow>
</AAT:Box>
<%
}
%>
