<%
my %arg = @_;

my @types = (defined $arg{any} ? Octopussy::Loglevel::List_And_Any(undef, undef)
	: Octopussy::Loglevel::List(undef, undef));
$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "loglevel"), 
	list => \@types, selected => $arg{selected});
%>
