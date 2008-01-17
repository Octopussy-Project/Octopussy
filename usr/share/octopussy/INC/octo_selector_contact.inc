<%
my %arg = @_;

my @list = Octopussy::Contact::List();

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "contact"), 
	multiple => (defined $arg{multiple} ? "1" : undef), 
	size => ($arg{size} || 5), list => \@list, selected => $arg{selected});
%>
