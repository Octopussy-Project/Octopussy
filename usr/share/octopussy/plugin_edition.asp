<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my $plugin = $Request->QueryString("plugin");
%>
<WebUI:PageTop title="Plugin Edition" />
<AAT:Inc file="octo_plugin_edition" 
	plugin="$plugin" url="./plugin_edition.asp" />
<WebUI:PageBottom />
