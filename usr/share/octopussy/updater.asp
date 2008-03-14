<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Updater" help="Updater" />
<%
my $form_fields = $Request->Form();
my @report_updates = ();
my @service_updates = ();
my @table_updates = ();
my @translation_updates = ();
foreach my $k (keys %{$form_fields})
{
	push(@report_updates, $1)  if ($k =~ /report_update_(.+)/);
	push(@service_updates, $1)	if ($k =~ /service_update_(\S+)/);
	push(@table_updates, $1)  if ($k =~ /table_update_(\S+)/);
	push(@translation_updates, $1)  if ($k =~ /translation_update_(\S+)/);
}
Octopussy::Report::Updates_Installation(@report_updates);
Octopussy::Service::Updates_Installation(@service_updates);
Octopussy::Table::Updates_Installation(@table_updates);
Octopussy::Updates_Installation(@translation_updates);
%>
<AAT:Inc file="octo_updater_reports_list" url="./updater.asp" />
<AAT:Inc file="octo_updater_services_list" url="./updater.asp" />
<AAT:Inc file="octo_updater_tables_list" url="./updater.asp" />
<WebUI:PageBottom />
