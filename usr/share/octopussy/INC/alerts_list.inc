<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @alerts = Octopussy::Alert::List();
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "alerts_table", url => $url, sort => $sort,
	header_icon => "buttons/bt_alert", header_title => "_ALERTS",
  function => "Octopussy::Alert::Configurations",
	function_args => [ $sort ],
	fields => [
		{ name => "name", label => "_NAME", style => "bold", alignment => "left" },
		{ name => "description", label => "_DESCRIPTION", alignment => "left" },
		{ name => "level", label => "_LEVEL", alignment => "left" },
		{ name => "type", label => "_TYPE", alignment => "left" },
		{ name => "status", label => "_STATUS", alignment => "left" } ],
	actions => [
		{ name => "edit", tooltip => "_EDIT", link_url => "./alert_edit.asp", 
			link_args => [ { name => "alert", field_value => "name" } ] },
		{ name => "remove", tooltip => "_REMOVE",
			link_url => "./dialog.asp", link_type => "popup",
      link_args => [ { name => "id", value => "delete_alert" },
                      { name => "arg1", field_value => "name" },
                      { name => "action", value => "remove" } ] }
		] );

my @items = ( 
	{ label => "_MSG_DYNAMIC_ALERT_CREATION", 
		link => "./alert_dynamic_creation.asp" } ); 
#	{ label => "_MSG_STATIC_ALERT_CREATION" } );
%>
<AAT:Menu align="C" items=\@items />
