<% 
my %arg = @_; 

my @plugin_funcs = Octopussy::Plugin::Functions(); 
my @fields = Octopussy::Table::Fields_Configurations($arg{table}, "title");
my @list = ();
push(@list, { label => "-NONE-", value => "" })	if ($arg{none} == 1);
foreach my $f (@fields)
{ 
	push(@list, $f->{title})	if ($f->{type} !~ /^DATE/); 
	foreach my $p_fc (@plugin_funcs)
	{
		foreach my $fc (AAT::ARRAY($p_fc->{functions}))
		{
			foreach my $fc_field (AAT::ARRAY($fc->{field}))
			{
				push(@list, { label => $p_fc->{plugin} . "::$fc->{label}($f->{title})",
					value => "$fc->{perl}($f->{title})" } )	
					if ("$arg{table}:$f->{title}" eq $fc_field);
			}
			foreach my $fc_ftype (AAT::ARRAY($fc->{field_type}))
      {
				push(@list, { label => $p_fc->{plugin} . "::$fc->{label}($f->{title})",
          value => "$fc->{perl}($f->{title})" } )
					if ($fc_ftype =~ /$f->{type}/);
			}
		}
	}
}
$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => $arg{name}, selected => $arg{selected}, list => \@list);
%>
