<%
my %arg = @_;

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "timeperiods_table", url => $arg{url}, sort => $arg{sort},
  header_icon => "buttons/bt_period", header_title => "_TIMEPERIODS",
  function => "Octopussy::TimePeriod::Configurations",
  function_args => [ $arg{sort} ],
  fields => [
    { name => "label", label => "_NAME", alignment => "left" },
    { name => "periods", label => "_PERIODS", alignment => "left" } ],
  actions => [
    { name => "remove", tooltip => "_REMOVE",
			link_url => "./dialog.asp", link_type => "popup",
      link_args => [ { name => "id", value => "delete_timeperiod" },
                      { name => "arg1", field_value => "label" },
                      { name => "action", value => "remove" }] } ],
  );
%>
