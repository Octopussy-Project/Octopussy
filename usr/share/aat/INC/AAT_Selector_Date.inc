<% 
my %arg = @_; 
my $url = $arg{url};
my @ltime = localtime(time);
my ($d, $mon, $y) = ($ltime[3], $ltime[4], $ltime[5]);
my $current_year = (1900 + $y);
my ($day, $month, $year) = (defined $arg{selected} ? split("/", $arg{selected}) 
	: ("", "", ""));
$day = ($day =~ /\d+/ ? $day : $d);
$day = ((($day < 10) && ($day !~ /^0/)) ? "0$day" : $day);
$month = ($month =~ /\d+/ ? $month : ($mon + 1));
$month = ((($month < 10) && ($month !~ /^0/)) ? "0$month" : $month);
$year = ($year =~ /\d+/ ? $year : (1900 + $y));

my @months = ();
my @days = ();
foreach my $i (1..12)
  { push(@months, ($i < 10 ? "0$i" : $i)); }
foreach my $i (1..31)
  { push(@days, ($i < 10 ? "0$i" : $i)); }
%>
<table>
<tr>
<td><% 
$Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{name} . "_day", list => \@days, 
	selected => $day, onchange => $arg{onchange}); 
%>/
<% $Response->Include('AAT/INC/AAT_Selector.inc',
		name => $arg{name} . "_month", list => \@months, 
	selected => $month, onchange => $arg{onchange});
%>/
<%
my $y1 = $arg{start_year} || 1900;
my $y2 = $arg{finish_year} || $current_year; 
$Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{name} . "_year", list => [$y1..$y2], 
	selected => $year, onchange => $arg{onchange});
%>
</td></tr>
</table>
