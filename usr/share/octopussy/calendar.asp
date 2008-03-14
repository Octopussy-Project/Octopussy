<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Calendar" help="Calendar" />
<%
my $url = $Request->QueryString("url");
my $dayfield = $Request->QueryString("dayfield");
my $monthfield = $Request->QueryString("monthfield");
my $yearfield = $Request->QueryString("yearfield");
%>
<AAT:Inc file="calendar" url="$url" dayfield="$dayfield" 
	monthfield="$monthfield" yearfield="$yearfield" />
<WebUI:PageBottom />
