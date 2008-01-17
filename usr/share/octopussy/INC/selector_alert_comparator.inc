<%
my %arg = @_;

my @list = Octopussy::Alert::Comparators();

$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => ($arg{name} || "comparator"), list => \@list);
%>
