<WebUI:PageTop title="_DEVICEGROUPS" help="devicegroups" />
<%
my $f = $Request->Form();
my $dg = $f->{devicegroup} || $Request->QueryString("devicegroup");
$dg = (Octopussy::DeviceGroup::Valid_Name($dg) ? $dg : undef);
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("devicegroups_table_sort");

if (NULL($dg))
{
	%><AAT:Inc file="octo_devicegroups_list" 
		url="./devicegroups.asp" sort="$sort" /><%
}
elsif ($Session->{AAT_ROLE} !~ /ro/i)
{
	if ($action eq "remove")
	{
		Octopussy::DeviceGroup::Remove($dg);
		AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "DeviceGroup", $dg, $Session->{AAT_LOGIN});
	}
	else
	{
		my $dg_desc = Encode::decode_utf8($f->{dg_description});
		my @criterias = ();
		if ($f->{type} eq "dynamic")
		{
			foreach my $i (1..3)
			{
				my $field = $f->{"criteria_field$i"};
				my $value = Encode::decode_utf8($f->{"criteria_value$i"});
				push(@criterias, { field => $field, pattern => $value })
					if (NOT_NULL($value));
			}	
			$Session->{AAT_MSG_ERROR} = 
				Octopussy::DeviceGroup::Add({ dg_id => $dg, description => $dg_desc,
        	type => "dynamic", criteria => \@criterias })
				if (scalar(@criterias) > 0);
		}
		else
		{
			$Session->{AAT_MSG_ERROR} =
				Octopussy::DeviceGroup::Add({ dg_id => $dg, description => $dg_desc,
					type => "static", device => $f->{devices} });
		}
		AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "DeviceGroup", $dg, $Session->{AAT_LOGIN})
			if (NOT_NULL($Session->{AAT_MSG_ERROR}));
	}
	$Response->Redirect("./devicegroups.asp");
}
%>
<WebUI:PageBottom />
