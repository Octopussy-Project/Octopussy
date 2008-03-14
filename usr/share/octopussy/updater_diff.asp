<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Updater" help="Updater" />
<%
my $service = $Request->QueryString("service");
my $table = $Request->QueryString("table");

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
