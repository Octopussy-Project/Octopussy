<%
my $devs = $Request->Form("devices");
my $selected = $Request->Form("selected");
my $restricted = $Request->Form("restricted");
my @devices = (AAT::NOT_NULL($devs) ? split(/,/, $devs) : undef);
my @selecteds = (AAT::NOT_NULL($selected) ? split(/,/, $selected) : undef);
my @restricteds = (AAT::NOT_NULL($restricted) ? split(/,/, $restricted) : undef);

my @device_list = ();
foreach my $d (@devices)
{
	if ($d =~ /^group .+$/)
		{ push(@device_list, Octopussy::DeviceGroup::Services($d)); }
	else
		{ push(@device_list, $d); }
}
my @list = ();
push(@list, ((AAT::NOT_NULL(@device_list))
	? sort(Octopussy::Device::Services(@device_list)) 
	: Octopussy::Service::List()));
@list = sort keys %{{ map { $_ => 1 } @list }}; # sort unique @list
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
<%
foreach my $item (@list)
{
	my $restrict = (AAT::NULL(@restricteds) ? 1 :0); # 1 = no restrictions
	foreach my $r (@restricteds)
		{ $restrict = 1	if ($r eq $item); }
	if ($restrict)
	{ # item in restrictions list (or no restrictions at all)
		my $match = 0;
		foreach my $s (@selecteds)
			{ $match = 1	if ($s =~ /^$item$/); }
	%><item label="<%= $item %>" selected="<%= $match %>" /><%
	}
}
%>
</root>
