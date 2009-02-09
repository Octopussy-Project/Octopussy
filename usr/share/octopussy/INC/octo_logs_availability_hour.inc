<%
my %arg = @_;
my ($device, $year, $month, $day, $hour) = ($arg{device}, $arg{year}, 
	AAT::Padding($arg{month}, 2), AAT::Padding($arg{day}, 2), $arg{hour});

my %start = ( year => $year, month => $month, day => $day, 
	hour => $hour, min => 0 );
my %finish = ( year => $year, month => $month, day => $day,
  hour => $hour, min => 59 );
my @services = Octopussy::Device::Services($device);

my $title = sprintf(
	AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"),$device);
my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
my $prev_nb_days = AAT::Datetime::Month_Nb_Days($year, $month-1);
my $link_prev = "./logs_availability.asp?device=$device"
  . (($hour =~ /^0?0$/)
		? (($day =~ /^0?1$/)
    	? (($month =~ /^0?1$/)
      	? "&year=" . ($year - 1) . "&month=12&day=31&hour=23"
      	: "&year=$year&month=" . ($month - 1) . "&day=" . $prev_nb_days . "&hour=23")
    	: "&year=$year&month=$month&day=" . ($day - 1) . "&hour=23")
		: "&year=$year&month=$month&day=$day&hour=" . AAT::Padding($hour - 1, 2));
my $link_next = "./logs_availability.asp?device=$device"
	. (($hour =~ /^23$/)
  	? (($day =~ /^$nb_days$/)
    	? (($month =~ /^12$/)
      	? "&year=" . ($year + 1) . "&month=1&day=1&hour=00"
      	: "&year=$year&month=" . ($month + 1) . "&day=1&hour=00")
    	: "&year=$year&month=$month&day=" . ($day + 1) . "&hour=00")
		: "&year=$year&month=$month&day=$day&hour=" . AAT::Padding($hour + 1, 2));
%>
<script type="text/javascript">
function logs_viewer_min(service,min)
{
	window.location = "logs_viewer.asp?device=<%= $device %>&service=" + service 
	+ "&dt1_year=<%= $year %>&dt1_month=<%= $month %>&dt1_day=<%= $day %>"
	+ "&dt1_hour=<%= $hour %>&dt1_min=" + min 
	+ "&dt2_year=<%= $year %>&dt2_month=<%= $month %>&dt2_day=<%= $day %>"
	+ "&dt2_hour=<%= $hour %>&dt2_min=" + min;
}
</script>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
  <AAT:BoxCol align="C">
  <table>
  <tr>
  <td><AAT:Button name="1leftarrow" link="$link_prev" /></td>
  <td><AAT:Label value="$day/$month/$year $hour:00 - $hour:59" style="B" size="+1" /></td>
  <td><AAT:Button name="1rightarrow" link="$link_next" /></td>
  </tr>
  </table>
  </AAT:BoxCol>
</AAT:BoxRow>
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
			? "gray" : "green");
  	%><td bgcolor="<%= $color %>" height="32" width="10" onclick="logs_viewer_min('-ANY-',<%= $min %>)"></td><%
  }
  %></tr>
	<tr><td colspan="62"><hr></td></tr>
	<%
	foreach my $service (sort @services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $m (0..59)
  	{
    	my $min = AAT::Padding($m, 2);
			my $color = (!defined $avail->{$service}{$month}{$day}{$hour}{$min} 
      	? "gray" : "green");
			%><td bgcolor="<%= $color %>" height="32" width="10" onclick="logs_viewer_min('<%= $service %>',<%= $min %>)"></td><%
		}
		%></tr><%
	}
	%>
	</table>
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
