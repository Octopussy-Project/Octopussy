<%
my $devs = $Request->QueryString("devices");
my $servs = $Request->QueryString("services");
my @devices = (AAT::NOT_NULL($devs) ? split(/,/, $devs) : undef);
my @services = (AAT::NOT_NULL($servs) ? split(/,/, $servs) : undef);
my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, sort(Octopussy::Taxonomy::List(\@devices, \@services)));
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
