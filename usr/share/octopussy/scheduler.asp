<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Scheduler" help="#scheduler_page" />
<AAT:Inc file="report_schedules_list" url="./scheduler.asp" sort="$sort" />
<%
my @items = ( 
	{ label => "_SCHEDULE_REPORT", link => "./report_scheduler.asp" },
#	{ label => "_SCHEDULE_STATISTIC_REPORT" } );
	);
%>
<AAT:Menu align="C" items=\@items />
<WebUI:PageBottom />
