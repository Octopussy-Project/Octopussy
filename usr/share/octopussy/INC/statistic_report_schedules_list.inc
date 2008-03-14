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
  header_icon => "buttons/bt_report", 
	header_title => "_STATISTICS_REPORT_SCHEDULER",
  function => "Octopussy::Schedule::Configurations",
  function_args => [ $sort ],

  fields => [
    { name => "title", label => "_TITLE", alignment => "left" },
    { name => "report", label => "_REPORT", alignment => "left" },
		{ name => "device", label => "_DEVICE", alignment => "left" },
		{ name => "service", label => "_SERVICE", alignment => "left" },
		{ name => "taxonomy", label => "_TAXONOMY", alignment => "left" },
		{ name => "start_time", label => "_START_TIME", alignment => "left" } ],
  actions => [
    { name => "remove", link_url => "./dialog.asp", link_type => "popup",
      link_args => [ 
				{ name => "id", value => "delete_statistic_report_schedule" },
        { name => "arg1", field_value => "title" },
       	{ name => "action", value => "remove" }] } ],
  );
%>
