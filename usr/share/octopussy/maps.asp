<WebUI:PageTop>
<table align="center">
<tr>
<%
my $map = $Request->QueryString("map");
$map = (($map =~ /^[a-z0-9][a-z0-9 _-]*$/i) ? $map : undef);
my $url = "./maps.asp";
my $website = Octopussy::Info::WebSite();
my @maps = Octopussy::Map::List();
$map = $maps[0]	if (scalar(@maps) == 1);
foreach my $m (@maps)
{
	%><td><a href="<%= $url . "?map=$m" %>"><%= $m %></a></td><%
}
if (scalar(@maps) == 0)
{
	%><td><a href="<%= $website %>/documentation/howtos/map" target="_blank">
	<%= AAT::Translation("_MSG_MAP_CREATION_INFO") %>
	</a></td><%
}
%>
</tr>
</table>
<%
if (defined $map)
{
	my $conf = Octopussy::Map::Configuration($map);
	%>
	<img src="./img_map.asp?map=<%= $map %>" usemap="#<%= $map %>" border=0>
	<map name="<%= $map %>">
	<%
	my $link = "./device_dashboard.asp?device=";
	foreach my $a (ARRAY($conf->{area}))
	{
	%><area shape="rect" 
			coords="<%= $a->{x1} %>,<%= $a->{y1} %>,<%= $a->{x2} %>,<%= $a->{y2} %>"
			href="<%= $link . $a->{device} %>" target="main"><%
	}
	%></map><%

	foreach my $a (ARRAY($conf->{area}))
	{
		my @alerts = Octopussy::Alert::From_Device($a->{device}, "Opened");
		if ((defined $a->{device}) && (scalar(@alerts) > 0))
		{
%>
<div style="position: absolute; left: <%= ($a->{x1} + ($a->{x2} - $a->{x1})/2) %>px; top: <%= $a->{y1} + 20 %>px;">
<a href="./alerts_viewer.asp?device=<%= $a->{device} %>&status=Opened" target="main">
<img src="IMG/dialogs/dialog-warning.png" border="0"></a>
</div>
<%
		}
	}
}
%>
</AAT:Page>
