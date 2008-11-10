<%
my $devs = $Request->QueryString("devices");
my $selected = $Request->QueryString("selected");
my @devices = (AAT::NOT_NULL($devs) ? split(/,/, $devs) : undef);
my @selecteds = (AAT::NOT_NULL($selected) ? split(/,/, $selected) : undef);
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
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
<%
foreach my $item (@list)
{
	my $match = 0;
	foreach my $s (@selecteds)
		{ $match = 1	if ($s =~ /^$item$/); }
%><item label="<%= $item %>" selected="<%= $match %>" /><%
}
%>
</root>
