<WebUI:PageTop title="_ALERTS_VIEWER" help="Alerts Viewer" />
<%
my $f = $Request->Form();
my $alert = $f->{alert} || $Request->QueryString("alert");
my $device = $f->{device} || $Request->QueryString("device");
my $status = $f->{status} || $Request->QueryString("status") || "Opened";
my $comment = $f->{comment};
my $sort = $Request->QueryString("sort");
my $sall = $f->{selectall};
if ((defined $f->{edit_status}) && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
{
	my $form_fields = $Request->Form();
	foreach my $k (keys %{$form_fields})
	{
		if ($k =~ /alert_id_(\d+)/)
		{
			my $id = $1;
			Octopussy::Alert::Update_Status($id, $f->{edit_status}, $comment);
			#AAT::NSCA::Send("Octopussy", 0, "OK: No Alerts !")	
			#	if (Octopussy::Alert::Check_All_Closed());
		}
	}
}
%>
<AAT:Inc file="octo_alerts_filter_box" url="./alerts_viewer.asp" 
	alert="$alert" device="$device" status="$status" />
<AAT:Inc file="octo_alerts_tracker" url="./alerts_viewer.asp" 
	alert="$alert" device="$device" status="$status" sort="$sort" 
	selectall="$sall" />
<WebUI:PageBottom />
