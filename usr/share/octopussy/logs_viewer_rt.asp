<%
my $f = $Request->Form();
%>
<WebUI:PageTop title="Real Time Logs" />
<script type="text/javascript" src="INC/octo_logs_viewer_rt.js"></script>
<%
if (defined $f->{logs})
{
%>
<script type="text/javascript">
RT_Init();
</script>
<%= "get" %><%
}

my @restricted_services = Octopussy::Service::List_Used();
$Response->Include("INC/octo_logs_viewer_rt_form.inc", url => $url, 
	unknown => 1, devices => \@devices, services => \@services,
	restricted_services => \@restricted_services);
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol align="C"><span id="timeout"></div> seconds</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
