<%
my %arg = @_;
my ($device, $year, $month, $day, $hour) = ($arg{device}, $arg{year}, 
	AAT::Padding($arg{month}, 2), AAT::Padding($arg{day}, 2), $arg{hour});

my %start = ( year => $year, month => $month, day => $day, 
	hour => $hour, min => 0 );
my %finish = ( year => $year, month => $month, day => $day,
  hour => $hour, min => 59 );
my @services = Octopussy::Device::Services($device);

my $title = sprintf(AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"),
  $device, "$day/$month/$year $hour:00-$hour:59");
my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
%>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
	<AAT:BoxCol>
	<table cellpadding="0" cellspacing="1">
	<tr>
	<td></td>
	<td></td>
	<%
	foreach my $m (0..59)
	{ 
		my $minute = AAT::Padding($m, 2);
		%><td><AAT:Label value="$minute" size="-1" /></td><%
	}
	%>
	</tr>
	<tr>
	<td><AAT:Button name="device" /></td>
	<td><AAT:Label value="$device" style="B" /></td><%
	foreach my $m (0..59)
  {
    my $min = AAT::Padding($m, 2);
    my $color = (!defined $avail->{_DEVICE_}{$month}{$day}{$hour}{$min} 
			? "red" : "green");
  	%><td bgcolor="<%= $color %>" height="32" width="10"></td><%
  }
  %></tr>
	<tr><td colspan="62"><hr></td></tr>
	<%
	foreach my $service (@services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $m (0..59)
  	{
    	my $min = AAT::Padding($m, 2);
			my $color = (!defined $avail->{$service}{$month}{$day}{$hour}{$min} 
      	? "red" : "green");
			%><td bgcolor="<%= $color %>" height="32" width="10"></td><%
		}
		%></tr><%
	}
	%>
	</table>
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
