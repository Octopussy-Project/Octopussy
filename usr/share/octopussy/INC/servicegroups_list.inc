<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "servicegroups_table", url => $url, sort => $sort,
  header_icon => "buttons/bt_servicegroup", header_title => "_SERVICEGROUPS",
  function => "Octopussy::ServiceGroup::Configurations",
  function_args => [ $sort ],

  fields => [
    { name => "sg_id", label => "_GROUP_NAME", alignment => "left" },
    { name => "description", label => "_DESCRIPTION", alignment => "left" },
    { name => "services", label => "_SERVICES", alignment => "left" } ],

  actions => [
		{ name => "edit", link_url => "./servicegroup_edit.asp",
			tooltip => "_EDIT",
			link_args => [ { name => "servicegroup", field_value => "sg_id" } ] },
    { name => "remove", link_url => "./dialog.asp",
      tooltip => "_REMOVE", link_type => "popup",
      link_args => [ { name => "id", value => "delete_servicegroup" },
                      { name => "arg1", field_value => "sg_id" },
                      { name => "action", value => "remove" }] } ],
  );

my @table = ( 
	[	{ type => "form", args => { method => "post", action => $url } },
		{ label => "_SERVICEGROUP", style => "bold" }, 
		{ label => "_DESCRIPTION", style => "bold" },
		{ label => "_SERVICES", style => "bold" } ],
	[ { label => "<hr>", colspan => 3 } ],
	[ { type => "AAT_Entry", args => { name => "servicegroup" } },
	  { type => "AAT_Entry", args => { name => "sg_description" } },
		{ type => "selector_multi_service", args => { name => "services" } } ],
 	[ { label => "<hr>", colspan => 3 } ],
 	[ { type => "AAT_Form_Submit", colspan => 3, align => "center",
    	args => { value => "_NEW_SERVICEGROUP" } }, { type => "end_form" } ] );

$Response->Include('INC/box.inc', elements => \@table);
%>
