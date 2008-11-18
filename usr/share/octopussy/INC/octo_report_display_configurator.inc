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
my $url = $arg{url};
$Session->{select} = \@selected;
%>
<AAT:Form action="$url">
<AAT:Form_Hidden name="selected" value="1" />
<AAT:Box align="C" title="_REPORT_FIELDS_ORDER">
<%
if ($Session->{graph_type} ne "array")
{%>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="X" /></AAT:BoxCol>
	<AAT:BoxCol cspan="3"><AAT:Selector name="x" list=\@selected /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="Y" /></AAT:BoxCol>
  <AAT:BoxCol cspan="3"><AAT:Selector name="y" list=\@selected /></AAT:BoxCol>
</AAT:BoxRow><%
}
else
{
%><AAT:Form_Hidden name="x" value="$selected[0]" /><%
	my $i = 0;
  foreach my $f (@selected)
  {%>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$f" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="column_name_$i" /></AAT:BoxCol><%
		if ($i > 0)
    { %>
	<AAT:BoxCol>
	<AAT:Button name="1uparrow" link="$url?field=$i&action=up" />
	</AAT:BoxCol><%
    }
    else
			{ %><AAT:BoxCol></AAT:BoxCol><% }
    if ($i < (scalar(@selected) - 1))
    { %>
	<AAT:BoxCol>
  <AAT:Button name="1downarrow" link="$url?field=$i&action=down" />
  </AAT:BoxCol><%
    }
    else
    	{ %><AAT:BoxCol></AAT:BoxCol><% }
		$i++;
%></AAT:BoxRow><%
	}
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="4">
	<AAT:Form_Submit value="_NEXT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
