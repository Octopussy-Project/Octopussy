<%
my %arg = @_;

my $device = $arg{device};
my $conf = Octopussy::Device::Configuration($device);
my $status = Octopussy::Device::Parse_Status($device);
my ($time, $device_events) = Octopussy::Stats::Events();
my $events = $device_events->{$device} || "0";
my @alerts = Octopussy::Alert::Opened_List($device);
my $nb_alerts = $#alerts+1;
my ($name, $address, $type, $model, $desc) = ($conf->{name}, $conf->{address}, 
	$conf->{type}, $conf->{model}, $conf->{description});
my @models = Octopussy::Device::Models($conf->{type});
my $icon = undef;
foreach my $m (@models)
{
  if ($m->{name} eq $conf->{model})
  {
    $icon = $m->{icon};
    last;
  }
}
my $str_status = ($status == 2 ? "Started" : ($status == 1 ? "Paused" : "Stopped"));
%>
<AAT:Box align="C">
  <AAT:BoxRow>
		<AAT:BoxCol><AAT:Label value="_DEVICE" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$name" /></AAT:BoxCol>
		<AAT:BoxCol><%= "($address)" %></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Label value="_DEVICE_TYPE" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
		<AAT:BoxCol align="C" rspan="2"><AAT:IMG name="$icon" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_DEVICE_MODEL" style="B" /></AAT:BoxCol>
    <AAT:BoxCol cspan="2"><AAT:Label value="$model" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
    <AAT:BoxCol cspan="2"><AAT:Label value="$desc" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_STATUS" style="B" /></AAT:BoxCol>
		<AAT:BoxCol cspan="2"><AAT:Label value="$str_status" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_LAST_LOGS" style="B" /></AAT:BoxCol>
    <AAT:BoxCol cspan="2"><AAT:Label value="$events" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_LAST_ALERTS" style="B" /></AAT:BoxCol>
    <AAT:BoxCol cspan="2"><AAT:Label value="$nb_alerts" 
			link="./alerts_viewer.asp?device=$device&status=Opened" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="C" cspan="3">
	<AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $s (Octopussy::Device::Services_Configurations($device, "rank"))
{
	my ($rank, $serv) = ($s->{rank}, $s->{sid});
	%><AAT:BoxRow><AAT:BoxCol align="R">
	<AAT:Label value="$rank" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Label value="$serv" link="./services.asp?service=$serv" />
	</AAT:BoxCol></AAT:BoxRow><%
}
%>
</AAT:Box>
