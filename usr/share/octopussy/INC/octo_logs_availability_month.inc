<%
my %arg = @_;
my ($device, $year, $month) = ($arg{device},  $arg{year}, $arg{month});
my $nb_days = AAT::Datetime::Month_Nb_Days($year, $month);

my %start = ( year => $year, month => $month, day => 1, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => $month, day => $nb_days,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $step = 2; # 2 hours step
my $title = sprintf(AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"),
  $device, "$month/$year");
%>
<AAT:Box align="C" title="$title">
<AAT:BoxRow>
	<AAT:BoxCol>
	<table cellpadding="0" cellspacing="1">
	<tr>
	<td></td>
	<td></td>
	<%
	foreach my $d (1..$nb_days)
	{ 
		my $day = AAT::Padding($d, 2);
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
    my $day = AAT::Padding($d, 2);
   	foreach my $i1 (0..11)
    {
    	my $have_logs = 0;
     	foreach my $i2 (0..$step-1)
     	{
      	my $hour = AAT::Padding(($i1*$step + $i2), 2);
       	$have_logs = 1  if (defined $avail->{_DEVICE_}{$day}{$hour});
     	}
      my $color = ($have_logs ? "green" : "red");
     	%><td bgcolor="<%= $color %>" height="32" width="2"></td><%
   	}
    %></tr></table></td><%
  }
	my $cspan = $nb_days + 2;
  %></tr>
	<tr><td colspan="<%= $cspan %>"><hr></td></tr>
	<%
	foreach my $service (@services)
	{
		%><tr><td><AAT:Button name="service" /></td>
		<td><AAT:Label value="$service" style="B" size="-1" /></td><%
		foreach my $d (1..$nb_days)
  	{
			%><td><table cellspadding="0" cellspacing="0"><tr><%
    	my $day = AAT::Padding($d, 2);
			foreach my $i1 (0..11)
			{
				my $have_logs = 0;
				foreach my $i2 (0..$step-1)
				{
					my $hour = AAT::Padding(($i1*$step + $i2), 2);
					$have_logs = 1	if (defined $avail->{$service}{$day}{$hour});
				}
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
