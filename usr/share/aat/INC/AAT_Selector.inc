<%
my %arg = @_;

my %selecteds = ();
foreach my $s (AAT::ARRAY($arg{selected}))
	{ $selecteds{$s} = 1; }
my %exclude = ();
foreach my $e (AAT::ARRAY($arg{exclude}))
	{ $exclude{$e} = 1; }
%>
<select <%= (defined $arg{multiple} ? "multiple " : "") %> <%= (defined $arg{size} ? "size=$arg{size} " : "") %> name="<%= $arg{name} %>"<%= (defined $arg{onchange} ? " onchange=\"$arg{onchange}\"" : "") %>><%	
foreach my $e (AAT::ARRAY($arg{list}))
{
	my $value = (ref $e eq "HASH" ? $e->{value} : $e);
	if (!defined $exclude{$value})
	{
		my $label = (ref $e eq "HASH" ? $e->{label} : $e);
		$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $value,
    	selected => (defined $selecteds{$value} ? " selected" : ""), 
			label => AAT::Translation($label) );
	}
} 
%>
</select>
