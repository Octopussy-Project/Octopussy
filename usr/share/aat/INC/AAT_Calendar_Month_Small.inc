<%
my %arg = @_;

my $w = (defined $arg{show_week} ? 1 : 0);
my ($y, $m, $d) = AAT::Datetime::Now();
my $nb_days = AAT::Datetime::Month_Nb_Days($y, $m);
my $month_name = AAT::Datetime::Month_Name($m);
my $nb_cols = (5+$w);
%>
<AAT:Box>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="&lt;&lt; " style="B" size="-2" /></AAT:BoxCol>
	<AAT:BoxCol align="center" cspan="$nb_cols">
	<AAT:Label value="$month_name" style="B" link="$arg{link_month}" />
	<AAT:Label value=" $y" style="B" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Label value=" &gt;&gt;" style="B" size="-2" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow style="box">
<%
if ($w)
{
%><AAT:BoxCol></AAT:BoxCol><%
}
for my $i (1..7)
{
	my $dname = AAT::Datetime::WeekDay_Name($i);
	my $value = substr(AAT::Translation($dname), 0, 3);
	%><AAT:BoxCol><AAT:Label value="$value" style="B" size="-2"/></AAT:BoxCol><%
}
%>
</AAT:BoxRow>
<AAT:BoxRow>
<%
my $week = AAT::Datetime::YearWeek($y, $m, 1);
if ($w)
{
%><AAT:BoxCol>
<AAT:Label value="$week" style="B" size="-3" link="$arg{link_week}"/>
</AAT:BoxCol><%
}
my $col = 1;
while ($col < AAT::Datetime::WeekDay($y, $m, 1))
{
  $col++;
  %><td class="calendar-day-null"></td><%
}
for my $i (1..$nb_days)
{
	%><td class="calendar-day-free">
	<AAT:Label value="$i" size="-3" link="$arg{link_day}"/></td><%
	if ($col == 7)
  {
		$week++;
		%></tr><tr class="box"><%
		if ($w)
		{
			%><AAT:BoxCol>
			<AAT:Label value="$week" style="B" size="-3" link="$arg{link_week}"/>
			</AAT:BoxCol><%
		}
  }
  $col = (($col == 7) ? 1 : ($col + 1));
}
my $i = 1;
while ($col <= 7)
{
  %><td class="calendar-day-null"><AAT:Label value="$i" size="-3"/></td><%
  $col++;
	$i++;
}
%>
</AAT:BoxRow>
</AAT:Box>
