<%
my %arg = @_;
my $url = $arg{url};
my $sort = $arg{sort};
my $lnk = "${url}?schedules_table_sort";
%>
<AAT:Box align="C" title="_REPORT_SCHEDULER" icon="buttons/bt_scheduler">
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_TITLE" link="$lnk=title" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_REPORT" link="$lnk=report" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DAY_OF_WEEK" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DAY_OF_MONTH" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_MONTH" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_START_TIME" link="$lnk=start_time" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_START_PERIOD" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_FINISH_PERIOD" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_ACTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="9"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $s (Octopussy::Schedule::Configurations($sort))
{
  my ($title, $report, $dow, $dom, $month, $start_time, $start_dt, $finish_dt) 
		= ($s->{title}, $s->{report}, join(", ", sort @{$s->{dayofweek}}), 
			join(", ", sort @{$s->{dayofmonth}}), join(", ", sort @{$s->{month}}), 
			$s->{start_time}, $s->{start_datetime}, $s->{finish_datetime});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$title" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$report" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$dow" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$dom" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$month" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$start_time" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$start_dt" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$finish_dt" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_report_schedule&arg1=$title&action=remove" />
	</AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
