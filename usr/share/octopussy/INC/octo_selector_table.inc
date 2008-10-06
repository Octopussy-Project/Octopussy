<%
my %arg = @_;

my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, (defined $arg{service} ? Octopussy::Service::Tables($arg{service}) 
	: Octopussy::Table::List()));

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "table"), 
	list => \@list, selected => $arg{selected});
%>
