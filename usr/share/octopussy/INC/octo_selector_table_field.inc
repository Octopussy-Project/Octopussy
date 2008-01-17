<% 
my %arg = @_; 

my $regexp = $arg{regexp};
my $orig = $arg{orig_msg};
my @fields = $orig =~ /$regexp/;
my $constant = $fields[$arg{field_number} - 1];
my @list = ( { label => "$constant", value => "CONST $constant" },
							{ label => "[NULL]", value => "NULL" } );
foreach my $e (Octopussy::Table::Field_Type_List($arg{table}, $arg{field_type}))
	{ push(@list, { label => "[" . uc($e) . "]", value => $e }); }
%>
<AAT:Selector name="table_field_$arg{field_number}" 
	list=\@list selected="$arg{selected}" />
