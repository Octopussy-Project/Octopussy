<WebUI:PageTop title="Device DashBoard" help="devices" />
<%
my $device = $Request->Form("device") || $Request->QueryString("device");
my $mode = $Request->QueryString("rrd_mode") || "daily";
if (!-f "./rrd/taxonomy_${device}_${mode}.png")
{
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Hourly_Graph($device);
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Daily_Graph($device);
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Weekly_Graph($device);
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Monthly_Graph($device);
	Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Yearly_Graph($device);
}
else
{
	my @stats = stat("./rrd/taxonomy_${device}_${mode}.png");
	if (((time() - $stats[9]) > 60) && ($mode eq "hourly"))
		{ Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Hourly_Graph($device); }
	elsif (((time() - $stats[9]) > (10*60)) && ($mode eq "daily"))
		{ Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Daily_Graph($device); }
	elsif (((time() - $stats[9]) > (30*60)) && ($mode eq "weekly"))
		{ Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Weekly_Graph($device); }
	elsif (((time() - $stats[9]) > (60*60)) && ($mode eq "monthly"))
		{ Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Monthly_Graph($device); }
	elsif (((time() - $stats[9]) > (720*60)) && ($mode eq "yearly"))
  	{ Octopussy::RRDTool::Syslog_By_Device_Taxonomy_Yearly_Graph($device); }
}
%>
<table>
<tr valign="top">
<td><AAT:Inc file="octo_device_dashboard" device="$device" /></td>
<td rowspan="2"><AAT:RRD_Graph url="./device_dashboard.asp?device=$device"
	name="taxonomy_$device" mode="$mode" /></td>
</tr>
</table>
<WebUI:PageBottom />
