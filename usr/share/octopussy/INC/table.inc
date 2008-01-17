<% 
my %arg = @_; 
my $url = $arg{url};
my $url_sort = $url . "?$arg{id}_sort=";

my @table = ();

my @header = ();
foreach my $field (@{$arg{fields}})
{
	push(@header, { label => ucfirst($field->{label}) || ucfirst($field->{name}), 
		style => "bold", align => $field->{alignment}, tooltip => $field->{tooltip},
		link => $url_sort . $field->{name} });	
}
push(@header, { label => "Action", style => "bold", 
	align => "center", colspan => $#{$arg{actions}} + 1 })
	if (defined $arg{actions});

push(@table, [ { type => "AAT_Picture", align => "right",
      args => { file => "buttons/bt_" . lc($arg{header}) . ".png" } },
	{ label => ucfirst($arg{header}), align => "left", size => "+1", 
		style => "bold", colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ]);
push(@table, [ { label => "<hr>", 
	colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ] );
push(@table, \@header);
push(@table, [ { label => "<hr>", 
	colspan => $#{$arg{fields}} + $#{$arg{actions}} + 2 } ] );

foreach my $line (&{$arg{function}}(@{$arg{function_args}}))
{
	my @row = ();
	foreach my $field (@{$arg{fields}})
	{
		my $link = (defined $field->{link_url} ? $field->{link_url} : $url) . "?";
		foreach my $la (@{$field->{link_args}})
		{ 
			$link .= "$la->{name}=" 
				. (defined $la->{field_value} ? $line->{$la->{field_value}} 
						: $la->{value}) . "&"; 
		}
		my $value = ((ref($line->{$field->{name}}) eq "ARRAY") 
			? join(", ", sort @{$line->{$field->{name}}})
			: $line->{$field->{name}});
		push(@row, { label => $value, align => $field->{alignment}, 
			style => $field->{style},
			link => ($link ne "$url?" ? $link : undef) } );
	}

	foreach my $a (@{$arg{actions}})	
	{
		my $link = (defined $a->{link_url} ? $a->{link_url} : $url) . "?";
		foreach my $la (@{$a->{link_args}})
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
				push(@row, { type => "button", align => "center", 
										args => { name => $name, tooltip => $a->{tooltip}, popup_link => $link } } );
			}
			else
			{
				push(@row, { type => "button", align => "center",
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
