<% 
my %arg = @_; 

my @plugin_funcs = Octopussy::Plugin::Functions(); 
my @fields = Octopussy::Table::Fields_Configurations($arg{table}, "title");
my @list = ();

foreach my $f (@fields)
{
  my ($title, $type) = ($f->{title}, $f->{type}); 
	push(@list, $title); 
	if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
	{
		push(@list, "AVG($title)", "MIN($title)", "MAX($title)");
	}
	push(@list, "COUNT($title)")	if ($type !~ /^BYTES$/);
	push(@list, "COUNT(DISTINCT($title))") if ($type !~ /^BYTES$/);
	if (($type =~ /^DATE/) || ($type =~ /^TIME/))
	{
		push(@list, "DAY($title)", "DAY_HOUR($title)", "DAY_HOUR_MIN($title)");
	}
	if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
	{
		push(@list, "SUM($title)");
	}
	
	foreach my $p_fc (@plugin_funcs)
	{
		foreach my $fc (ARRAY($p_fc->{functions}))
		{
      my $fct = $fc->{perl};
			my $label = $p_fc->{plugin} . "::$fc->{label}";
			foreach my $fc_field (ARRAY($fc->{field}))
			{
				if ("$arg{table}:$f->{title}" eq $fc_field)
				{
					push(@list, { label => "$label($title)", value => "$fct($title)" } );
					if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
    			{ 
						push(@list, { label => "$label(AVG($title))", 
                          value => "$fct(AVG($title))" }); 
						push(@list, { label => "$label(MIN($title))",
                          value => "$fct(MIN($title))" });
						push(@list, { label => "$label(MAX($title))",
                          value => "$fct(MAX($title))" });
					}
					push(@list, { label => "$label(COUNT($title))", 
					              value => "$fct(COUNT($title))" });
					push(@list, { label => "$label(COUNT(DISTINCT($title)))", 
					              value => "$fct(COUNT(DISTINCT($title)))" });
					if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
          {
            push(@list, { label => "$label(SUM($title))", 
					                value => "$fct(SUM($title))" });
          }
				}
			}
			foreach my $fc_ftype (ARRAY($fc->{field_type}))
      {
				if ($fc_ftype =~ /$type/)
				{
					push(@list, { label => "$label($title)", value => "$fct($title)" } );
					if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
          {
            push(@list, { label => "$label(AVG($title))",
                          value => "$fct(AVG($title))" });
            push(@list, { label => "$label(MIN($title))",
                          value => "$fct(MIN($title))" });
            push(@list, { label => "$label(MAX($title))",
                          value => "$fct(MAX($title))" });
          }
          #push(@list, { label => "$label(COUNT($title))",
          #  value => "$fct(COUNT($title))" });
          #push(@list, { label => "$label(COUNT(DISTINCT($title)))",
          #  value => "$fct(COUNT(DISTINCT($title)))" });
          if (($type =~ /NUMBER$/) || ($type =~ /^BYTES$/))
          {
            push(@list, { label => "$label(SUM($title))",
                          value => "$fct(SUM($title))" });
          }
				}
			}
		}
	}
}

$Response->Include('AAT/INC/AAT_Selector.inc', name => $arg{name}, 
	multiple => 1, size => 20, list => \@list);
%>
