<%
my %arg = @_;

my @list = ("-NONE-");
push(@list, Octopussy::Search_Template::List());

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "search_template"), 
	list => \@list, selected => $arg{selected});
%>
