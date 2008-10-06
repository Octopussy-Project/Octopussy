<%
my %arg = @_;

my @list = Octopussy::Configuration::Backup_List();

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "backup"), 
	list => \@list, selected => $arg{selected});
%>
