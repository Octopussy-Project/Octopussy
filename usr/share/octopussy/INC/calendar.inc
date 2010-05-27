<%
my %arg = @_;
my $url = $arg{url};
my $dayfield = $arg{dayfield} || "day";
my $monthfield = $arg{monthfield} || "month";
my $yearfield = $arg{yearfield} || "year";
my $arg_str = "";
foreach my $k (keys %arg)
	{ $arg_str .= "&$k=$arg{$k}"; }
%>
<%
my ($y, $m, $d) = AAT::Utils::Now();
$m = $Request->QueryString("month") || $m;
$y = $Request->QueryString("year") || $y;
my $prev_m = ($m > 1 ? $m - 1 : 12);
my $prev_y = ($m > 1 ? $y : $y - 1);
my $next_m = ($m < 12 ? $m + 1 : 1);
my $next_y = ($m < 12 ? $y : $y + 1);
my $nb_days = AAT::Datetime::Month_Nb_Days($y, $m);
my $link_prev = "./calendar.asp?year=$prev_y&month=$prev_m&$arg_str";
my $link_next = "./calendar.asp?year=$next_y&month=$next_m&$arg_str";
my $month_name = AAT::Datetime::Month_Name($m);
my $month_str = AAT::Translation($month_name) . " $y";
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><b><a href="<%= $link_prev %>"> << </a></b></AAT:BoxCol>
	<AAT:BoxCol cspan="5" align="C">
	<AAT:Label value="$month_str" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><b><a href="<%= $link_next %>"> >> </a></b></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow><%
for my $i (1..7)
{
  my $dname = AAT::Datetime::WeekDay_Name($i);
	my $d_str = substr(AAT::Translation($dname), 0, 3);
%><AAT:BoxCol><AAT:Label value="$d_str" style="B" /></AAT:BoxCol><%
}
%>
</AAT:BoxRow>
<%
my $col = 0;
my $row = 0;
while ($col < AAT::Datetime::WeekDay($y, $m, 1))
{ 
	$rows[$row][$col] = { label => "" };
	$col++; 
}

for my $i (1..$nb_days)
{
  my $day_link = "";
  if ($url =~ /.+\?.+/)
  {
    $day_link = "$url&$dayfield=" . (($i < 10) && ($i !~ /^0/) ? "0$i" : $i)
      . "&$monthfield=" . (($m < 10) && ($m !~ /^0/) ? "0$m" : $m) . "&$yearfield=$y";
  }
  else
  {
    $day_link = "$url?$dayfield=" . (($i < 10) && ($i !~ /^0/) ? "0$i" : $i)
      . "&$monthfield=" . (($m < 10) && ($m !~ /^0/) ? "0$m" : $m) . "&$yearfield=$y";
  }
  $rows[$row][$col-1] = { label => (($i < 10) && ($i !~ /^0/) ? "0$i" : $i), link => $day_link };
  $row++  if ($col == 7);
  $col = ($col == 7 ? 1 : $col + 1);
}
while ($col <= 7)
{
  $rows[$row][$col-1] = { label => "" };
  $col++;
}
foreach my $row (@rows)
{ 
	%><AAT:BoxRow><%
	foreach my $col (@{$row})
	{
		my ($label, $link) = ($col->{label}, $col->{link});
	%><AAT:BoxCol align="R">
	<AAT:Label value="$label" link="$link"/></AAT:BoxCol><%
	}
	%></AAT:BoxRow><%
}
%>
</AAT:Box>
