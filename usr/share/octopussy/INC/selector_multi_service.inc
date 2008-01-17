<%
my %arg = @_;
my $name = $arg{name} || "multi_service";
my @services = Octopussy::Service::List();

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	multiple => 1, size => 3, list => \@services);
%>
