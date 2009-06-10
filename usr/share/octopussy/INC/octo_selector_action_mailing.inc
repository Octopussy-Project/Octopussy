<%
my %arg = @_;
my $name = $arg{name} || "action_mailing";
my @actions = ("Jabber", "Mail");

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@actions, selected => $arg{selected}, multiple => $arg{multiple}, 
  size => $arg{size} );
%>
