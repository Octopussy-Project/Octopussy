<% 
my %arg = @_; 
my $name = $arg{name} || "rrd_timeline";
my @fields = Octopussy::Table::Fields_Configurations($arg{table}, "title");
my @list = ();

foreach my $f (@fields)
{ 
	push(@list, "UNIX_TIMESTAMP($f->{title})")
		if (($f->{type} =~ /^DATE/) || ($f->{type} =~ /^TIME/));
}
$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	size => ($#list > 2 ? 3 : $#list), list => \@list);
%>
