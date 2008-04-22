<%
my %arg = @_;

my $action = $Session->{action};
my $i = $Session->{field};
my @selected = AAT::ARRAY($Session->{select});

my $tmp = $selected[$i];
if ($action eq "up")
{
	$selected[$i] = $selected[$i-1];
	$selected[$i-1] = $tmp;
}
elsif ($action eq "down")
{
	$selected[$i] = $selected[$i+1];
	$selected[$i+1] = $tmp;
}

$Session->{select} = \@selected;

my @box = (
	[ { type => "AAT_Form_Hidden", args => { name => "selected", value => 1 } },
		{ type => "form", args => { method => "post", action => $arg{url} } },
   	{ label => "_REPORT_FIELDS_ORDER", align => "center", 
			style => "bold", colspan => 4 } ],
 	[ { label => "<hr>", colspan => 4 } ] );

if ($Session->{graph_type} ne "array")
{
	push(@box, [ { label => "X" }, 
		{ type => "AAT_Selector", colspan => 3,
			args => { name => "x", list => \@selected } } ]);
	push(@box, [ { label => "Y" },
		{ type => "AAT_Selector", colspan => 3,
			args => { name => "y", list => \@selected } } ]);
}
else
{
	my $url = "./report_creation.asp";
	push(@box, [ { type => "AAT_Form_Hidden", 
		args => { name => "x", value => $selected[0] } } ]);
	my $i = 0;
	foreach my $f (@selected)
	{
		my @row = ( { label => $f }, 
			{ type => "AAT_Entry", args => { name => "column_name_$i" } } );
		if ($i > 0)
		{
			push(@row, { type => "AAT_Button", 
				args => { name => "1uparrow", link => "$url?field=$i&action=up" } } );
		}
		else
			{ push(@row, { label => "" }); }
		if ($i < $#selected)
		{
			push(@row, { type => "AAT_Button", 
				args => { name => "1downarrow", link => "$url?field=$i&action=down" } } );
		}
		else
			{ push(@row, { label => "" }); }
		push(@box, \@row);
		$i++;
	}
}
push(@box, [ { label => "<hr>", colspan => 4 } ],
	[ { type => "AAT_Form_Submit", colspan => 4, align => "center",
   		args => { value => "_NEXT" } }, { type => "end_form" } ] );
$Response->Include('INC/box.inc', elements => \@box);
%>
