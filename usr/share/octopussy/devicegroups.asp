<WebUI:PageTop title="Devices" help="devicegroups" />
<%
my $f = $Request->Form();
my $dg = $f->{devicegroup} || $Request->QueryString("devicegroup");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("devicegroups_table_sort");

if (AAT::NULL($dg))
{
	%><AAT:Inc file="octo_devicegroups_list" 
		url="./devicegroups.asp" sort="$sort" /><%
}
elsif ($Session->{AAT_ROLE} !~ /ro/i)
{
	if ($action eq "remove")
	{
		Octopussy::DeviceGroup::Remove($dg);
		AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "DeviceGroup", $dg);
	}
	else
	{
		my $dg_desc = $f->{dg_description};
		my @criterias = ();
		if ($f->{type} eq "dynamic")
		{
			foreach my $i (1..3)
			{
				my $field = $f->{"criteria_field$i"};
				my $value = $f->{"criteria_value$i"};
				push(@criterias, { field => $field, pattern => $value })
					if (AAT::NOT_NULL($value));
			}	
			$Session->{AAT_MSG_ERROR} = 
				Octopussy::DeviceGroup::Add({ dg_id => $dg, description => $dg_desc,
        	type => "dynamic", criteria => \@criterias })
				if ($#criterias >= 0);
		}
		else
		{
			$Session->{AAT_MSG_ERROR} =
				Octopussy::DeviceGroup::Add({ dg_id => $dg, description => $dg_desc,
					type => "static", device => $f->{devices} });
		}
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "DeviceGroup", $dg)
			if (AAT::NOT_NULL($Session->{AAT_MSG_ERROR}));
	}
	$Response->Redirect("./devicegroups.asp");
}
%>
<WebUI:PageBottom />
