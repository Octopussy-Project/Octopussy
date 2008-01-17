<%
my %arg = @_;
my $url = $arg{url};
my $dayfield = $arg{dayfield};
my $monthfield = $arg{monthfield};
my $yearfield = $arg{yearfield};
my $arg_str = "";
foreach my $k (keys %arg)
	{ $arg_str .= "&$k=$arg{$k}"; }
%>
<%
my ($y, $m, $d) = AAT::Datetime::Now();
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

my @table = (
	[ { label => "<<", link => $link_prev, align => "left", style => "bold" },
		{ label => AAT::Translation($month_name) . " $y", 
			align => "center", style => "bold", colspan => 5 }, 
		{ label => ">>", link => $link_next, align => "right", style => "bold" } ],
	[ { label => "<hr>", colspan => 7 } ] );
my @row_week = ();
for my $i (1..7)
{
	my $dname = AAT::Datetime::WeekDay_Name($i); 
	$dname = AAT::Translation($dname);
	push(@row_week, { label => substr($dname, 0, 3), style => "bold" } ); 
}
push(@table, \@row_week);
push(@table, [ { label => "<hr>", colspan => 7 } ] );
my $col = 0;
my $row = 0;
while ($col < AAT::Datetime::WeekDay($y, $m, 1))
	{ $col++; }
my @rows = ();
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
	$row++	if ($col == 7);
	$col = ($col == 7 ? 1 : $col + 1);
}
while ($col <= 7)
{ 
	$rows[$row][$col-1] = { label => "" }; 
	$col++;
}
foreach my $row (@rows)
	{ push(@table, $row); }
%>
<% $Response->Include('INC/box.inc', elements => \@table) %>
