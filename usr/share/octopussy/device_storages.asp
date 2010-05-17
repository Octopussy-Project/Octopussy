<WebUI:PageTop title="Device Storages" help="devices" />
<%
my $device = $Request->QueryString("device");
my $f = $Request->Form();

if ($Session->{AAT_ROLE} !~ /ro/)
{
	if ($f->{action} eq "update")
	{
		my $conf = Octopussy::Device::Configuration($device);
		my @services = ();
		foreach my $s (ARRAY($conf->{service}))
		{
			my $serv = $s->{sid};
			if (defined $f->{"logrotate_$serv"})
			{
				push(@services, { sid => $serv, rank => $s->{rank}, 
					logrotate => $f->{"logrotate_$serv"} });
			}
			else
				{ push(@services, { sid => $serv, rank => $s->{rank} }); }
		}
		foreach my $k (keys %{$f})
			{ $conf->{$k} = $f->{$k}	if ($k =~ /^storage_.+$/); }

		$conf->{service} = \@services;	
		Octopussy::Device::Modify($conf);
	}
}
%>
<AAT:Inc file="octo_device_storages_default" device="$device" 
	url="./device_storages.asp?device=$device" />
<WebUI:PageBottom />
