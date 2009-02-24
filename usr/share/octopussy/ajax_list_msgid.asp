<%
my $servs = $Request->QueryString("services");
my $loglevel = $Request->QueryString("loglevel");
my $taxonomy = $Request->QueryString("taxonomy");
my $selected = $Request->QueryString("selected");
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