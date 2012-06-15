<WebUI:PageTop title="Table Fields" />
<%
my $f = $Request->Form();
my $q = $Request->QueryString();
my $table = $f->{table} || $q->{table};
$table = (Octopussy::Table::Valid_Name($table) ? $table : undef);
$Response->Redirect("./tables.asp")	if (NULL($table));
my $field = $f->{fieldname} || $q->{fieldname};
my $sort = $q->{table_fields_table_sort};

if ((defined $field) && ($field !~ /^\s*$/) 
	&& ($Session->{AAT_ROLE} =~ /^(admin|rw)$/i))
{
	$field =~ s/ /_/g;
  	if ($q->{action} eq "remove")
	{ 
		Octopussy::Table::Remove_Field($table, $field); 
		AAT::Syslog::Message("octo_WebUI", "GENERIC_REMOVED_FROM", 
			"Table Field", $field, "Table", $table, $Session->{AAT_LOGIN});
	}
	else
	{ 
		Octopussy::Table::Add_Field($table, $field, $f->{type}); 
		AAT::Syslog::Message("octo_WebUI", "GENERIC_ADDED_TO",
			"Table Field", $field, "Table", $table, $Session->{AAT_LOGIN});
	}
}
%>
<AAT:Inc file="octo_tablefields_list" url="./table_fields.asp" 
	table="$table" sort="$sort" />
<WebUI:PageBottom />
