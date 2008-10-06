<%
my %arg = @_;

my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, sort(Octopussy::Taxonomy::List()));

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "taxonomy"), 
	list => \@list, selected => $arg{selected});
%>
