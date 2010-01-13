<%
my $servs = $Request->Form("services");
my $loglevel = $Request->Form("loglevel");
my $taxonomy = $Request->Form("taxonomy");
my $selected = $Request->Form("selected");
my @list = (defined $arg{any} ? ("-ANY-") : ());

my @services = (AAT::NOT_NULL($servs) ? split(/,/, $servs) : undef);
push(@list, sort(Octopussy::Message::List(\@services, $loglevel, $taxonomy)));
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
