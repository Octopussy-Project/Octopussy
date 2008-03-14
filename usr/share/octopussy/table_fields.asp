<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Table Fields" />
<%
my $f = $Request->Form();
my $table = $f->{table} || $Request->QueryString("table");
my $fieldname = $f->{fieldname} || $Request->QueryString("fieldname");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("table_fields_table_sort");

if ((defined $fieldname) && ($fieldname !~ /^\s*$/) 
		&& ($Session->{AAT_ROLE} !~ /ro/i))
{
	$fieldname =~ s/ /_/g;
  if ($action eq "remove")
	{ 
		Octopussy::Table::Remove_Field($table, $fieldname); 
		AAT::Syslog("octo_WebUI", "GENERIC_REMOVED_FROM", 
			"Table Field", $fieldname, "Table", $table);
	}
	else
	{ 
		Octopussy::Table::Add_Field($table, $fieldname, $f->{type}); 
		AAT::Syslog("octo_WebUI", "GENERIC_ADDED_TO",
			"Table Field", $fieldname, "Table", $table);
	}
}
%>
<AAT:Inc file="octo_tablefields_list" url="./table_fields.asp" 
	table="$table" sort="$sort" />
<WebUI:PageBottom />
