<%
my ($time, $device_events) = Octopussy::Stats::Events();
my $total = 0;
foreach my $k (keys %{$device_events})
  { $total += $device_events->{$k}; }
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol>
  <AAT:Label value="_MSG_TOTAL_EVENTS_LAST_MINUTE" style="B" size="-1" />
  <AAT:Label value=" ($time)" style="B" size="-1" />
  </AAT:BoxCol>
  <AAT:BoxCol align="R">
	<AAT:Label value="$total" style="B" size="-1" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $k (sort keys %{$device_events})
{
	my $events = $device_events->{$k};
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$k" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="$events" size="-1" /></AAT:BoxCol>
</AAT:BoxRow><%
}%>
</AAT:Box>
