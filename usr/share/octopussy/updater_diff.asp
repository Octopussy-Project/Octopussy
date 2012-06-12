<WebUI:PageTop title="Updater" help="Updater" />
<%
my $service = $Request->QueryString("service");
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
my $table = $Request->QueryString("table");
$table = (Octopussy::Table::Valid_Name($table) ? $table : undef);

if (defined $service)
{
%><AAT:Inc file="octo_updater_diff_service_list" service="$service" /><%
}
elsif (defined $table)
{
%><AAT:Inc file="octo_updater_diff_table_list" table="$table" /><%
}
%>
<WebUI:PageBottom />
