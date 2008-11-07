<%
my $devs = $Request->QueryString("devices");
my @devices = (AAT::NOT_NULL($devs) ? split(/,/, $devs) : undef);
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
foreach my $i (@list)
{
%><item><%= $i %></item><%
}
%>
</root>
