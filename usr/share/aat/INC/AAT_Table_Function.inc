<% 
my %arg = @_; 
my $url = $arg{url};
my $url_sort = $url . "?$arg{id}_sort=";
my @table = ();

my @header = ();
foreach my $field (AAT::ARRAY($arg{fields}))
{
	push(@header, { label => ucfirst($field->{label}) || ucfirst($field->{name}), 
		style => "bold", align => $field->{alignment}, tooltip => $field->{tooltip},
		link => $url_sort . $field->{name} });	
}
push(@header, { label => "_ACTION", style => "bold", 
	align => "center", colspan => $#{$arg{actions}} + 1 })
	if (defined $arg{actions});

push(@table, [ { type => "AAT_IMG", align => "right",
      args => { name => $arg{header_icon} } },
	{ label => $arg{header_title}, align => "left", size => "+1", 
		style => "bold", colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ]);
push(@table, [ { label => "<hr>", 
	colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ] );
push(@table, \@header);
push(@table, [ { label => "<hr>", 
	colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ] );

foreach my $line (&{$arg{function}}(AAT::ARRAY($arg{function_args})))
{
	my @row = ();
	foreach my $field (AAT::ARRAY($arg{fields}))
	{
		my $link = (defined $field->{link_url} ? $field->{link_url} : $url) . "?";
		foreach my $la (AAT::ARRAY($field->{link_args}))
		{ 
			$link .= "$la->{name}=" 
				. (defined $la->{field_value} ? $line->{$la->{field_value}} 
						: $la->{value}) . "&"; 
		}
		my $value = ((ref($line->{$field->{name}}) eq "ARRAY") 
			? join(", ", sort(AAT::ARRAY($line->{$field->{name}})))
			: $line->{$field->{name}});
		if (!defined $field->{type})
		{
			push(@row, { label => $value, align => $field->{alignment}, 
				style => $field->{style},
				link => ($link ne "$url?" ? $link : undef) } );
		}
		elsif ($field->{type} =~ /IMG/)
		{
			push(@row, { type => "AAT_IMG", align => $field->{alignment},
				args => { name => $value, width => 32 } } );
		}
	}

	foreach my $a (AAT::ARRAY($arg{actions}))	
	{
		my $link = (defined $a->{link_url} ? $a->{link_url} : $url) . "?";
		foreach my $la (AAT::ARRAY($a->{link_args}))
    { 
			$link .= "$la->{name}=" 
				. (defined $la->{field_value} ? $line->{$la->{field_value}} 
					: $la->{value}) . "&"; 
		}
		my $name = (defined $a->{name_fct}
    	? &{$a->{name_fct}}($line->{$a->{name_fct_args}}) : $a->{name});
		if (($Session->{AAT_ROLE} !~ /ro/i) 
				&& ((!defined $a->{condition})
						|| (&{$a->{condition}}($line->{$a->{condition_args}})))) 
		{
			if ($a->{link_type} eq "popup")
			{
				push(@row, { type => "AAT_Button", align => "center", 
										args => { name => $name, tooltip => $a->{tooltip}, popup_link => $link } } );
			}
			else
			{
				push(@row, { type => "AAT_Button", align => "center",
        	          args => { name => $name, tooltip => $a->{tooltip}, link => $link } } );
			}
		}
		else
			{ push(@row, { label => "" }); }
	}
	push(@table, \@row);
}
%>
<% $Response->Include('INC/box.inc', elements => \@table, bicolor => 1) %>
