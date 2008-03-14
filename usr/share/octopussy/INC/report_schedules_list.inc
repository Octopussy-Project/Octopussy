<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $url = $arg{url};
my $sort = $arg{sort};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "schedules_table", url => $url, sort => $sort || "title",
  header_icon => "buttons/bt_scheduler", header_title => "_REPORT_SCHEDULER",
  function => "Octopussy::Schedule::Configurations",
  function_args => [ $sort ],

  fields => [
    { name => "title", label => "_TITLE", alignment => "left" },
    { name => "report", label => "_REPORT", alignment => "left" },
		{ name => "dayofweek", label => "_DAY_OF_WEEK", alignment => "left" }, 
		{ name => "dayofmonth", label => "_DAY_OF_MONTH", alignment => "left" },
		{ name => "month", label => "_MONTH", alignment => "left" },
		{ name => "start_time", label => "_START_TIME", alignment => "left" }, 
		{ name => "start_datetime", label => "_START_PERIOD" }, 
		{ name => "finish_datetime", label => "_FINISH_PERIOD" } ],

  actions => [
    { name => "remove", link_url => "./dialog.asp", link_type => "popup",
      link_args => [ { name => "id", value => "delete_report_schedule" },
                      { name => "arg1", field_value => "title" },
                      { name => "action", value => "remove" }] } ],
  );
%>
