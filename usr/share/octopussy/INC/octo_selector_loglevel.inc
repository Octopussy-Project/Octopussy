<%
my %arg = @_;

my @types = (defined $arg{any} ? ("-ANY-") : ());
push(@types, ("Emergency", "Alert", "Critical", "Warning", "Notice", 
	"Information", "Debug"));

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "loglevel"), 
	list => \@types, selected => $arg{selected});
%>
