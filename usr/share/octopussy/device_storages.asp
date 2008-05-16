<WebUI:PageTop title="Device Storages" help="devices" />
<%
my $device = $Request->QueryString("device");
my $f = $Request->Form();

if ($Session->{AAT_ROLE} !~ /ro/)
{
	if ($f->{action} eq "update")
	{
		my $conf = Octopussy::Device::Configuration($device);
		foreach my $k (keys %{$f})
			{ $conf->{$k} = $f->{$k}	if ($k =~ /storage_.+$/); }
		Octopussy::Device::Modify($conf);
	}
}
%>
<AAT:Inc file="octo_device_storages_default" device="$device" 
	url="./device_storages.asp?device=$device" />
<AAT:BackButton />
<WebUI:PageBottom />
