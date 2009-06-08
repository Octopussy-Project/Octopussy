<%
my %arg = @_;
my $name = $arg{name} || "action";
my @actions = ("Jabber", "Mail", "NSCA", "Zabbix");

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@actions, selected => $arg{selected} );
%>
