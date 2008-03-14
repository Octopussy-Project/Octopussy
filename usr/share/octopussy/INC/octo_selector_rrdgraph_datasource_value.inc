<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my $name = $arg{name} || "datasources_value";
my @plugin_funcs = Octopussy::Plugin::Functions(); 
my @fields = Octopussy::Table::Fields_Configurations($arg{table}, "title");
my @list = ();

foreach my $f (@fields)
{
	if ($f->{type} !~ /^DATE/)
	{
		push(@list, $f->{title})	if ($f->{type} =~ /NUMBER$/); 
		push(@list, "AVG($f->{title})")	if ($f->{type} =~ /NUMBER$/);
		push(@list, "COUNT($f->{title})");
		push(@list, "COUNT(DISTINCT($f->{title}))");
		push(@list, "SUM($f->{title})")	if ($f->{type} =~ /NUMBER$/);
	
		foreach my $p_fc (@plugin_funcs)
		{
			foreach my $fc (AAT::ARRAY($p_fc->{functions}))
			{
				foreach my $fc_field (AAT::ARRAY($fc->{field}))
				{
					push(@list, { label => "$p_fc->{plugin}::$fc->{label}($f->{title})",
						value => "$fc->{perl}($f->{title})" } )	
						if ("$arg{table}:$f->{title}" eq $fc_field);
				}
				foreach my $fc_ftype (AAT::ARRAY($fc->{field_type}))
      	{
					push(@list, { label => "$p_fc->{plugin}::$fc->{label}($f->{title})",
          	value => "$fc->{perl}($f->{title})" } )
						if ($fc_ftype =~ /$f->{type}/);
				}
			}
		}
	}
}
$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	selected => $arg{selected}, list => \@list);
%>
