<%
my $devs = $Request->QueryString("devices");
my $servs = $Request->QueryString("services");
my $table = $Request->QueryString("table");
my $selected = $Request->QueryString("selected");
my @list = (defined $arg{any} ? ({ value => "-ANY-", color => "black" }) : ());

if (NOT_NULL($table))
{
  my ($dgs, $devices, $services) = 
		Octopussy::Table::Devices_and_Services_With($table);
  push(@list, sort(Octopussy::Loglevel::List($devices, $services)));
}
else
{
	my @devices = (NOT_NULL($devs) ? split(/,/, $devs) : undef);
	my @services = (NOT_NULL($servs) ? split(/,/, $servs) : undef);
	push(@list, sort(Octopussy::Loglevel::List(\@devices, \@services)));
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
<%
foreach my $item (@list)
{
	my ($value, $color, $level) = 
		($item->{value}, $item->{color}, $item->{level});
  my $sel = ($value =~ /^$selected$/ ? "1" : "0");
%><item label="<%= $value %>" level="<%= $level %>" color="<%= $color %>" selected="<%= $sel %>" /><%
}
%>
</root>
