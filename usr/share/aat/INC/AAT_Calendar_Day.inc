<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my ($y, $m, $d) = AAT::Utils::Now();
my $dname = AAT::Datetime::WeekDay_Name($d);
my $month_name = AAT::Datetime::Month_Name($m);
%>
<AAT:Box width="100%">
<AAT:BoxRow style="box">
	<AAT:BoxCol><AAT:Label value="&lt;&lt; " style="B" size="-2" /></AAT:BoxCol>
	<AAT:BoxCol align="C" width="100%" cspan="$nb_cols">
	<AAT:Label value="$dname" style="B" /><%= " $d " %>
	<AAT:Label value="$month_name" style="B" link="$arg{link_month}" />
	<AAT:Label value=" $y" style="B" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Label value=" &gt;&gt;" style="B" size="-2" /></AAT:BoxCol>
</AAT:BoxRow>
<%
for my $i (0..23)
{
	my $hour = ($i<10 ? "0$i" : $i);
	%><AAT:BoxRow style="box">
	<td class="calendar-time-free" colspan="3">
	<AAT:Label value="$hour:00" style="B" link="$arg{link_time}" />
	</td></AAT:BoxRow>
	<AAT:BoxRow style="box">   <td class="calendar-time-free" colspan="3">
  <AAT:Label value="$hour:30" style="B" link="$arg{link_time}" />
  </td></AAT:BoxRow>	
	<%
}
%>
</AAT:Box>
