<%
my %arg = @_;

my %selecteds = ();
foreach my $s (ARRAY($arg{selected}))
	{ $selecteds{$s} = 1; }
my %exclude = ();
foreach my $e (ARRAY($arg{exclude}))
	{ $exclude{$e} = 1; }
%>
<select <%= (defined $arg{multiple} ? "multiple " : "") %> <%= (defined $arg{size} ? "size=$arg{size} " : "") %> id="<%= $arg{name} %>" name="<%= $arg{name} %>"<%= (defined $arg{onchange} ? " onchange=\"$arg{onchange}\"" : "") %>>
<%	
foreach my $e (ARRAY($arg{list}))
{
	print $e->{value};
	my $value = (ref $e eq "HASH" ? $e->{value} : $e);
	if (!defined $exclude{$value})
	{
		my $label = (ref $e eq "HASH" ? ($e->{label} || $e->{value}): $e);
		my $style =  (((ref $e eq "HASH") && (defined $e->{color})) 
			? "color:$e->{color}" : undef);
		my $str_label = ((defined $arg{no_trans} || $label !~ /^_/)
			? $label : AAT::Translation($label));
		$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $value,
    	style => $style, label => $str_label,
			selected => (defined $selecteds{$value} ? " selected" : "") );
	}
} 
%>
</select>
