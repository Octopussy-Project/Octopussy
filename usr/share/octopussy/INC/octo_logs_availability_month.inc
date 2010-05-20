<%
my $COLOR_AVAILABLE = "green";
my $COLOR_NOT_AVAILABLE = "gray";

my %arg = @_;
my ($device, $year, $month) = ($arg{device},  $arg{year}, 
	sprintf("%02d", $arg{month}));
my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);

my %start = ( year => $year, month => $month, day => 1, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => $month, day => $nb_days,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $step = 2; # 2 hours step
my $title = sprintf(
	AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"), $device);
my $link_prev = "./logs_availability.asp?device=$device"
	. (($month =~ /^0?1$/) 
		? "&year=" . ($year - 1) . "&month=12" 
		: "&year=$year&month=" . ($month - 1));
my $link_next = "./logs_availability.asp?device=$device"
	. (($month =~ /^12$/)
		? "&year=" . ($year + 1) . "&month=1"
		: "&year=$year&month=" . ($month + 1));
%>
<script type="text/javascript">
function logs_viewer_day(service,day)
{
  window.location = "logs_viewer.asp?device=<%= $device %>&service=" + service 
  + "&dt1_year=<%= $year %>&dt1_month=<%= $month %>&dt1_day=" + day
  + "&dt1_hour=00&dt1_min=00" 
  + "&dt2_year=<%= $year %>&dt2_month=<%= $month %>&dt2_day=" + day
  + "&dt2_hour=23&dt2_min=59";
}
</script>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
  <AAT:BoxCol align="C">
  <table>
  <tr>
  <td><AAT:Button name="1leftarrow" link="$link_prev" /></td>
  <td><AAT:Label value="$month/$year" style="B" size="+1" /></td>
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
	foreach my $d (1..$nb_days)
	{ 
		my $day = sprintf("%02d", $d);
		my $link = "./logs_availability.asp?device=$device"
			. "&year=$year&month=$month&day=$day";
		%><td><AAT:Label value="$day" link="$link" size="-1" /></td><%
	}
	%>
	</tr>
	<tr>
	<td><AAT:Button name="device" /></td>
	<td><AAT:Label value="$device" style="B" /></td><%
	foreach my $d (1..$nb_days)
  {
  	%><td><table cellspadding="0" cellspacing="0"><tr><%
    my $day = sprintf("%02d", $d);
   	foreach my $i1 (0..11)
    {
    	my $have_logs = 0;
     	foreach my $i2 (0..$step-1)
     	{
      	my $hour = sprintf("%02d", ($i1*$step + $i2));
       	$have_logs = 1  if (defined $avail->{_DEVICE_}{$month}{$day}{$hour});
     	}
      my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
     	%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_day('-ANY-',<%= $day %>)"></td><%
   	}
    %></tr></table></td><%
  }
	my $cspan = $nb_days + 2;
  %></tr>
	<tr><td colspan="<%= $cspan %>"><hr></td></tr>
	<%
	foreach my $service (sort @services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $d (1..$nb_days)
  	{
			%><td><table cellspadding="0" cellspacing="0"><tr><%
    	my $day = sprintf("%02d", $d);
			foreach my $i1 (0..11)
			{
				my $have_logs = 0;
				foreach my $i2 (0..$step-1)
				{
					my $hour = sprintf("%02d", ($i1*$step + $i2));
					$have_logs = 1	if (defined $avail->{$service}{$month}{$day}{$hour});
				}
				my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
				%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_day('<%= $service %>',<%= $day %>)"></td><%
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
