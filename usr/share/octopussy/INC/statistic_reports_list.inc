<%
$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "statistic_reports_table", url => $url, sort => $sort || "name",
  header_icon => "buttons/bt_report", header_title => "_STATISTICS_REPORTS",
  function => "Octopussy::Statistic_Report::Configurations",
  function_args => [ $sort ],
  fields => [
    { name => "name", label => "_NAME", alignment => "left",
      link_args => [ { name => "report", field_value=> "name" } ] },
    { name => "description", label => "_DESCRIPTION", alignment => "left" } ],
  actions => [
    { name => "edit", tooltip => "_EDIT",
			link_url => "./statistic_report_edit.asp",
      link_args => [ { name => "statistic_report", field_value => "name" } ] },
    { name => "remove", tooltip => "_REMOVE",
			link_url => "./dialog.asp",
			link_type => "popup",
      link_args => [ { name => "id", value => "delete_statistic_report" },
                      { name => "arg1", field_value => "name" },
                      { name => "action", value => "remove" }] } ] );
%>
