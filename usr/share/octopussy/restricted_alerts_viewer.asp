<WebUI:PageTopRestricted title="Restricted Alerts Viewer" />
<%
my $restrictions = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN}, $Session->{AAT_USER_TYPE});
my @restricted_devices = ARRAY($restrictions->{device});
my @restricted_alerts = ARRAY($restrictions->{alert});

my $f = $Request->Form();
my $alert = $f->{alert} || $Request->QueryString("alert");
$alert = (Octopussy::Alert::Valid_Name($alert) ? $alert : undef);
my $device = $f->{device} || $Request->QueryString("device");
$device = (Octopussy::Device::Valid_Name($device) ? $device : undef);
my $status = $f->{status} || $Request->QueryString("status") || "Opened";
$status = (Octopussy::Alert::Valid_Status_Name($status) ? $status : "Opened");

if (defined $f->{edit_status})
{
	my $form_fields = $Request->Form();
	foreach my $k (keys %{$form_fields})
	{
		if ($k =~ /alert_id_(\d+)/)
		{
			my $id = $1;
			Octopussy::Alert::Update_Status($id, $f->{edit_status}, 
				$Server->HTMLEncode($comment));
			#AAT::NSCA::Send(0, "OK: No Alerts !")
			#	if (Octopussy::Alert::Check_All_Closed());
		}
	}
}
$Response->Include("INC/octo_alerts_filter_box.inc", 
	url => "./alerts_viewer.asp", alert => $alert, device => $device, 
	status => $status, 
	restricted_alerts => \@restricted_alerts,
	restricted_devices => \@restricted_devices);
$Response->Include("INC/octo_alerts_tracker.inc", 
	url => "./alerts_viewer.asp", alert => $alert, device => $device, 
	status => $status, 
	restricted_alerts => \@restricted_alerts,
	restricted_devices => \@restricted_devices);
%>
<WebUI:PageBottom />
