<WebUI:PageTop title="Table Fields" />
<%
my $f = $Request->Form();
my $q = $Request->QueryString();
my $table = $f->{table} || $q->{table};
$Response->Redirect("./tables.asp")	if (AAT::NULL($table));
my $field = $f->{fieldname} || $q->{fieldname};
my $sort = $q->{table_fields_table_sort};

if ((defined $field) && ($field !~ /^\s*$/) && ($Session->{AAT_ROLE} !~ /ro/i))
{
	$field =~ s/ /_/g;
  if ($q->{action} eq "remove")
	{ 
		Octopussy::Table::Remove_Field($table, $field); 
		AAT::Syslog("octo_WebUI", "GENERIC_REMOVED_FROM", 
			"Table Field", $field, "Table", $table);
	}
	else
	{ 
		Octopussy::Table::Add_Field($table, $field, $f->{type}); 
		AAT::Syslog("octo_WebUI", "GENERIC_ADDED_TO",
			"Table Field", $field, "Table", $table);
	}
}
%>
<AAT:Inc file="octo_tablefields_list" url="./table_fields.asp" 
	table="$table" sort="$sort" />
<WebUI:PageBottom />
