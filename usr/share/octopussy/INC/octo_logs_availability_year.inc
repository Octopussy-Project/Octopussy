<%
my %arg = @_;
my ($device, $year) = ($arg{device},  $arg{year});

my %start = ( year => $year, month => 1, day => 1, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => 12, day => 31,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $title = sprintf(AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"),
  $device, "$year");
%>
<AAT:Box align="C" icon="buttons/bt_player_playlist" title="$title">
<AAT:BoxRow>
	<AAT:BoxCol>
	<table cellpadding="0" cellspacing="1">
	<tr>
	<td></td>
	<td></td>
	<%
	foreach my $m (1..12)
	{ 
		my $month = AAT::Padding($m, 2);
		my $link = "./logs_availability.asp?device=$device"
			. "&year=$year&month=$month";
		%><td><AAT:Label value="$month" link="$link" size="-1" /></td><%
	}
	%>
	</tr>
	<tr>
	<td><AAT:Button name="device" /></td>
	<td><AAT:Label value="$device" style="B" /></td><%
	foreach my $m (1..12)
  {
  	%><td><table cellspadding="0" cellspacing="0"><tr><%
    my $month = AAT::Padding($m, 2);
		my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
   	foreach my $i1 (1..$nb_days)
    {
    	my $have_logs = 0;
     	my $day = AAT::Padding($i1, 2);
      $have_logs = 1  if (defined $avail->{_DEVICE_}{$month}{$day});
      my $color = ($have_logs ? "green" : "red");
     	%><td bgcolor="<%= $color %>" height="32" width="2"></td><%
   	}
    %></tr></table></td><%
  }
	my $cspan = 14;
  %></tr>
	<tr><td colspan="<%= $cspan %>"><hr></td></tr>
	<%
	foreach my $service (@services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $m (1..12)
  	{
			%><td><table cellspadding="0" cellspacing="0"><tr><%
    	my $month = AAT::Padding($m, 2);
			my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);
			foreach my $i1 (1..$nb_days)
			{
				my $have_logs = 0;
				my $day = AAT::Padding($i1, 2);
				$have_logs = 1	if (defined $avail->{$service}{$month}{$day});
				my $color = ($have_logs ? "green" : "red");
				%><td bgcolor="<%= $color %>" height="32" width="2"></td><%
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
