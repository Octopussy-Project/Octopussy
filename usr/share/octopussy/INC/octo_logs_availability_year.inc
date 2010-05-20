<%
my $COLOR_AVAILABLE = "green";
my $COLOR_NOT_AVAILABLE = "gray";

my %arg = @_;
my ($device, $year) = ($arg{device},  $arg{year});

my %start = ( year => $year, month => 1, day => 1, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => 12, day => 31,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $title = sprintf(
	AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"), $device);
my $link_prev = "./logs_availability.asp?device=$device&year=" . ($year - 1);
my $link_next = "./logs_availability.asp?device=$device&year=" . ($year + 1);
%>
<script type="text/javascript">
function logs_viewer_month(service,month,nb_days)
{
  window.location = "logs_viewer.asp?device=<%= $device %>&service=" + service 
  + "&dt1_year=<%= $year %>&dt1_month=" + month 
	+ "&dt1_day=01&dt1_hour=00&dt1_min=00" 
  + "&dt2_year=<%= $year %>&dt2_month=" + month 
	+ "&dt2_day=" + nb_days + "&dt2_hour=23&dt2_min=59";
}
</script>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
  <AAT:BoxCol align="C">
	<table>
	<tr>
	<td><AAT:Button name="1leftarrow" link="$link_prev" /></td>
	<td><AAT:Label value="$year" style="B" size="+1" /></td>
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
	foreach my $m (1..12)
	{ 
		my $month_name =  AAT::Datetime::Month_Name($m);
		my $month = sprintf("%02d", $m)
		my $link = "./logs_availability.asp?device=$device"
			. "&year=$year&month=$month";
		%><td><AAT:Label value="$month_name" link="$link" size="-2" /></td><%
	}
	%>
	</tr>
	<tr>
	<td><AAT:Button name="device" /></td>
	<td><AAT:Label value="$device" style="B" /></td><%
	foreach my $m (1..12)
  {
  	%><td><table cellspadding="0" cellspacing="0"><tr><%
    my $month = sprintf("%02d", $m);
		my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
   	foreach my $i1 (1..$nb_days)
    {
    	my $have_logs = 0;
     	my $day = sprintf("%02d", $i1);
      $have_logs = 1  if (defined $avail->{_DEVICE_}{$month}{$day});
      my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
     	%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_month('-ANY-',<%= $month %>,<%= $nb_days %>)"></td><%
   	}
    %></tr></table></td><%
  }
	my $cspan = 14;
  %></tr>
	<tr><td colspan="<%= $cspan %>"><hr></td></tr>
	<%
	foreach my $service (sort @services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $m (1..12)
  	{
			%><td><table cellspadding="0" cellspacing="0"><tr><%
    	my $month = sprintf("%02d", $m);
			my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
			foreach my $i1 (1..$nb_days)
			{
				my $have_logs = 0;
				my $day = sprintf("%02d", $i1);
				$have_logs = 1	if (defined $avail->{$service}{$month}{$day});
				my $color = ($have_logs ? $COLOR_AVAILABLE : $COLOR_NOT_AVAILABLE);
				%><td bgcolor="<%= $color %>" height="32" width="2" onclick="logs_viewer_month('<%= $service %>',<%= $month %>,<%= $nb_days %>)"></td><%
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
