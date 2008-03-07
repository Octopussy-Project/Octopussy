<% 
my %arg = @_; 

my @plugin_funcs = Octopussy::Plugin::Functions(); 
my @fields = Octopussy::Table::Fields_Configurations($arg{table}, "title");
my @list = ();

foreach my $f (@fields)
{ 
	push(@list, $f->{title}); 
	if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
	{
		push(@list, "AVG($f->{title})");
		push(@list, "MIN($f->{title})");
		push(@list, "MAX($f->{title})");
	}
	push(@list, "COUNT($f->{title})")	if ($f->{type} !~ /^BYTES$/);
	push(@list, "COUNT(DISTINCT($f->{title}))") if ($f->{type} !~ /^BYTES$/);
	if (($f->{type} =~ /^DATE/) || ($f->{type} =~ /^TIME/))
	{
		push(@list, "DAY($f->{title})");
		push(@list, "DAY_HOUR($f->{title})");
		push(@list, "DAY_HOUR_MIN($f->{title})");
	}
	if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
	{
		push(@list, "SUM($f->{title})");
	}
	
	foreach my $p_fc (@plugin_funcs)
	{
		foreach my $fc (AAT::ARRAY($p_fc->{functions}))
		{
			my $label = $p_fc->{plugin} . "::$fc->{label}";
			foreach my $fc_field (AAT::ARRAY($fc->{field}))
			{
				if ("$arg{table}:$f->{title}" eq $fc_field)
				{
					push(@list, { label => "$label($f->{title})",
												value => "$fc->{perl}($f->{title})" } );
					if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
    			{ 
						push(@list, { label => "$label(AVG($f->{title}))", 
													value => "$fc->{perl}(AVG($f->{title}))" }); 
						push(@list, { label => "$label(MIN($f->{title}))",
                          value => "$fc->{perl}(MIN($f->{title}))" });
						push(@list, { label => "$label(MAX($f->{title}))",
                          value => "$fc->{perl}(MAX($f->{title}))" });
					}
					push(@list, { label => "$label(COUNT($f->{title}))", 
												value => "$fc->{perl}(COUNT($f->{title}))" });
					push(@list, { label => "$label(COUNT(DISTINCT($f->{title})))", 
												value => "$fc->{perl}(COUNT(DISTINCT($f->{title})))" });
					if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
          {
            push(@list, { label => "$label(SUM($f->{title}))", 
													value => "$fc->{perl}(SUM($f->{title}))" });
          }
				}
			}
			foreach my $fc_ftype (AAT::ARRAY($fc->{field_type}))
      {
				if ($fc_ftype =~ /$f->{type}/)
				{
					push(@list, { label => "$label($f->{title})",
          	value => "$fc->{perl}($f->{title})" } );
					if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
          {
            push(@list, { label => "$label(AVG($f->{title}))",
                          value => "$fc->{perl}(AVG($f->{title}))" });
            push(@list, { label => "$label(MIN($f->{title}))",
                          value => "$fc->{perl}(MIN($f->{title}))" });
            push(@list, { label => "$label(MAX($f->{title}))",
                          value => "$fc->{perl}(MAX($f->{title}))" });
          }
          #push(@list, { label => "$label(COUNT($f->{title}))",
          #              value => "$fc->{perl}(COUNT($f->{title}))" });
          #push(@list, { label => "$label(COUNT(DISTINCT($f->{title})))",
          #              value => "$fc->{perl}(COUNT(DISTINCT($f->{title})))" });
          if (($f->{type} =~ /NUMBER$/) || ($f->{type} =~ /^BYTES$/))
          {
            push(@list, { label => "$label(SUM($f->{title}))",
                          value => "$fc->{perl}(SUM($f->{title}))" });
          }
				}
			}
		}
	}
}

$Response->Include('AAT/INC/AAT_Selector.inc', name => $arg{name}, 
	multiple => 1, size => 20, list => \@list);
%>
