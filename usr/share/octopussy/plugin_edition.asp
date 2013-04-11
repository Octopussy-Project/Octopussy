<WebUI:PageTop title="Plugin Edition" />
<%
my $plugin = $Request->QueryString("plugin");
%>
<AAT:Inc file="octo_plugin_edition" 
	plugin="$plugin" url="./plugin_edition.asp" />
<WebUI:PageBottom />
