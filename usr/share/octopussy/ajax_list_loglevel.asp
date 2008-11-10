<%
my $devs = $Request->QueryString("devices");
my $servs = $Request->QueryString("services");
my $selected = $Request->QueryString("selected");
my @devices = (AAT::NOT_NULL($devs) ? split(/,/, $devs) : undef);
my @services = (AAT::NOT_NULL($servs) ? split(/,/, $servs) : undef);
my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, sort(Octopussy::Loglevel::List(\@devices, \@services)));
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
<%
foreach my $item (@list)
{
	my $sel = ($item =~ /^$selected$/ ? "1" : "0");
%><item label="<%= $item %>" selected="<%= $sel %>" /><%
}
%>
</root>
