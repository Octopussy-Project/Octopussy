<%
my %arg = @_;
$arg{re_label} ||= ".+";
$arg{re_value} ||= ".+";
$arg{selected} ||= $conf->{selected_by_default};
my %selecteds = ();
if (ref $arg{selected} eq "ARRAY")
{
	foreach my $s (AAT::ARRAY($arg{selected}))
		{ $selecteds{$s} = 1; }
}
else
{ 
	$selecteds{$arg{selected}} = 1	if (defined $arg{selected}); 
}
%>
<select <%= (defined $arg{multiple} ? "multiple " : "") %> <%= (defined $arg{size} ? "size=$arg{size} " : "") %> name="<%= $arg{name} %>"><%	
foreach my $e (AAT::List::Items($arg{list}))
{
	if (($e->{value} =~ /$arg{re_value}/) && ($e->{label} =~ /$arg{re_label}/))
	{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $e->{value},
    selected => (defined $selecteds{$e->{value}} ? " selected" : ""), 
		label => AAT::Translation($e->{label}) );
	}
} 
%>
</select>
