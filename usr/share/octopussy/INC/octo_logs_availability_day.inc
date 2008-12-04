<%
my %arg = @_;
my ($device, $year, $month, $day) 
	= ($arg{device},  $arg{year}, $arg{month}, AAT::Padding($arg{day}, 2));

my %start = ( year => $year, month => $month, day => $day, 
	hour => 0, min => 0 );
my %finish = ( year => $year, month => $month, day => $day,
  hour => 23, min => 59 );
my @services = Octopussy::Device::Services($device);

my $avail = Octopussy::Logs::Availability($device, \%start, \%finish);
my $step = 5; # 5 minutes step
my $title = sprintf(AAT::Translation("_MSG_LOGS_AVAILABILITY_FOR_DEVICE"),
	$device, "$day/$month/$year");
%>
<AAT:Box align="C" title="$title">
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
       	$have_logs = 1  if (defined $avail->{_DEVICE_}{$day}{$hour}{$min});
     	}
      my $color = ($have_logs ? "green" : "red");
     	%><td bgcolor="<%= $color %>" height="32" width="2"></td><%
   	}
    %></tr></table></td><%
  }
  %></tr>
	<tr><td colspan="26"><hr></td></tr>
	<%
	foreach my $service (@services)
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
					$have_logs = 1	if (defined $avail->{$service}{$day}{$hour}{$min});
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
