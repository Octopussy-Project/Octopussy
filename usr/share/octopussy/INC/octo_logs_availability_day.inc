<%
my $COLOR_AVAILABLE = "green";
my $COLOR_NOT_AVAILABLE = "gray";

my %arg = @_;
my ($device, $year, $month, $day) = ($arg{device},  $arg{year}, 
	AAT::Padding($arg{month}, 2), AAT::Padding($arg{day}, 2));

my %start = ( year => $year, month => $month, day => $day, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => $month, day => $day,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $step = 5; # 5 minutes step
my $title = sprintf(
	AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"), $device);
my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
my $prev_nb_days = AAT::Datetime::Month_Nb_Days($year, $month-1);
my $link_prev = "./logs_availability.asp?device=$device"
  . (($day =~ /^0?1$/)
		? (($month =~ /^0?1$/)
    	? "&year=" . ($year - 1) . "&month=12&day=31" 
    	: "&year=$year&month=" . ($month - 1) . "&day=" . $prev_nb_days)
		: "&year=$year&month=$month&day=" . ($day - 1));
my $link_next = "./logs_availability.asp?device=$device"
	. (($day =~ /^$nb_days$/)
		? (($month =~ /^12$/)
    	? "&year=" . ($year + 1) . "&month=1&day=1"
    	: "&year=$year&month=" . ($month + 1) . "&day=1")
		: "&year=$year&month=$month&day=" . ($day + 1));
%>
<script type="text/javascript">
function logs_viewer_hour(service,hour)
{
  window.location = "logs_viewer.asp?device=<%= $device %>&service=" + service 
  + "&dt1_year=<%= $year %>&dt1_month=<%= $month %>&dt1_day=<%= $day %>"
  + "&dt1_hour=" + hour + "&dt1_min=00" 
  + "&dt2_year=<%= $year %>&dt2_month=<%= $month %>&dt2_day=<%= $day %>"
  + "&dt2_hour=" + hour + "&dt2_min=59";
}
</script>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
  <AAT:BoxCol align="C">
  <table>
  <tr>
  <td><AAT:Button name="1leftarrow" link="$link_prev" /></td>
  <td><AAT:Label value="$day/$month/$year" style="B" size="+1" /></td>
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
	foreach my $h (0..23)
	{ 
		my $hour = AAT::Padding($h, 2);
		my $link = "./logs_availability.asp?device=$device"
			. "&year=$year&month=$month&day=$day&hour=$hour";
		%><td><AAT:Label value="$hour" link="$link" size="-1" /></td><%
	}
	%>
	</tr>
	<tr>
	<td><AAT:Button name="device" /></td>
	<td><AAT:Label value="$device" style="B" /></td><%
	foreach my $h (0..23)
  {
  	%><td><table cellspadding="0" cellspacing="0"><tr><%
    my $hour = AAT::Padding($h, 2);
   	foreach my $i1 (0..11)
    {
    	my $have_logs = 0;
     	foreach my $i2 (0..$step-1)
     	{
      	my $min = AAT::Padding(($i1*$step + $i2), 2);
       	$have_logs = 1  if (defined $avail->{_DEVICE_}{$month}{$day}{$hour}{$min});
     	}
      my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
     	%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_hour('-ANY-',<%= $hour %>)"></td><%
   	}
    %></tr></table></td><%
  }
  %></tr>
	<tr><td colspan="26"><hr></td></tr>
	<%
	foreach my $service (sort @services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $h (0..23)
  	{
			%><td><table cellspadding="0" cellspacing="0"><tr><%
    	my $hour = AAT::Padding($h, 2);
			foreach my $i1 (0..11)
			{
				my $have_logs = 0;
				foreach my $i2 (0..$step-1)
				{
					my $min = AAT::Padding(($i1*$step + $i2), 2);
					$have_logs = 1	if (defined $avail->{$service}{$month}{$day}{$hour}{$min});
				}
				my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
				%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_hour('<%= $service %>',<%= $hour %>)"></td><%
			}
			%></tr></table></td><%	
		}
		%></tr><%
	}
	%>
	</table>
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
