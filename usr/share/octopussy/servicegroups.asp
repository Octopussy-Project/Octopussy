<WebUI:PageTop title="_SERVICEGROUPS" help="servicegroups" />
<%
my $f = $Request->Form();
my $sg = $f->{servicegroup} || $Request->QueryString("servicegroup");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("servicegroups_table_sort");

if (NULL($sg))
{
	%><AAT:Inc file="octo_servicegroups_list" url="./servicegroups.asp" 
		sort="$sort" /><%
}
elsif ($Session->{AAT_ROLE} !~ /ro/i)
{
	if ($action eq "remove")
	{
		Octopussy::ServiceGroup::Remove($sg);
		AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "ServiceGroup", $sg, $Session->{AAT_LOGIN});
		$Response->Redirect("./servicegroups.asp");
	}
	else
	{
		my $sg_desc = $f->{sg_description};
		my @services = ();
		my $rank = 1;
		foreach my $s (ARRAY($f->{services}))
		{ 
			push(@services, { rank => sprintf("%02d", $rank), sid => $s }); 
			$rank++;
		}
		Octopussy::ServiceGroup::Add({ sg_id => $sg, description => $sg_desc,
			service => \@services });
		AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "ServiceGroup", $sg, $Session->{AAT_LOGIN});
		$Response->Redirect("./servicegroups.asp");
	}
}
%>
<WebUI:PageBottom />
