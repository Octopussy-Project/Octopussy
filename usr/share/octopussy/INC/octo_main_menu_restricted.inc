<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my @main_menu = ();

push(@main_menu,
#  { icon => "buttons/bt_alert", 
#		label => "_ALERTS", link => "./alerts.asp" },
#  { icon => "buttons/bt_contact", 
#		label => "_CONTACTS", link => "./contacts.asp" },
#  { icon => "buttons/bt_messages", 
#		label => "_MESSAGES", link => "./messages.asp" },
#  { icon => "buttons/bt_report", 
#		label => "_REPORTS", link => "./reports.asp" },
#  { icon => "buttons/bt_scheduler", 
#		label => "_SCHEDULER", link => "./scheduler.asp" },
#  { icon => "buttons/bt_period", 
#		label => "_TIMEPERIODS", link => "./timeperiods.asp" },
#  { separator => 1 },
  { icon => "buttons/bt_alert", 
		label => "_ALERTS_VIEWER", link => "./restricted_alerts_viewer.asp" },
  { icon => "buttons/bt_search",
		label => "_LOGS_VIEWER", link => "./restricted_logs_viewer.asp" },
  { icon => "buttons/bt_report", 
		label => "_REPORTS_VIEWER", link => "./restricted_reports_viewer.asp" } );

$Response->Include('AAT/INC/AAT_Menu.inc', items => \@main_menu);
%>
