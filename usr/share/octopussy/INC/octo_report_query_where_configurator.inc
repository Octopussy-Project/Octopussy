<%
my %arg = @_;
my $url = $arg{url};
my $table = $Session->{table};
my @list = ("ASCENDING", "DESCENDING");

my ($query, $columns) =
	Octopussy::DB::SQL_Select_Function(ARRAY($Session->{select}));
my $group_by_str = join(", ", @{$Session->{group_by}});
my $order_by_str = join(", ", @{$Session->{order_by}});
%>
<AAT:Form action="$url">
<%
foreach my $k (keys %arg)
  { %><AAT:Form_Hidden name="$k" value="$arg{$k}" /><% }
%>
<AAT:Form_Hidden name="selected" value="1" />
<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol cspan="3" align="C">
  <AAT:Label value="_SQL_QUERY_DEFINITION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><AAT:Label value="$query" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><b>WHERE</b></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="where" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><b><%= "GROUP BY $group_by_str" %></b></AAT:BoxCol>
</AAT:BoxRow>
<% foreach my $c (@{$Session->{group_by}})
{  
%><AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$c" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Button name="remove" link="$url?group_by_remove=$c"/></AAT:BoxCol>
</AAT:BoxRow><%
}
foreach my $c (@{$columns})
{
	my $match = 0;
	foreach my $c2 (@{$Session->{group_by}})
		{ $match = 1 if ($c2 eq $c); } 
	if (! $match)
	{
%><AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$c" /></i></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="add" link="$url?group_by_add=$c"/></AAT:BoxCol>
</AAT:BoxRow><%
	}
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><b><%= "ORDER BY $order_by_str" %></b></AAT:BoxCol>
</AAT:BoxRow>
<% foreach my $c (@{$Session->{order_by}})
{
%><AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$c" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Button name="remove" link="$url?order_by_remove=$c"/></AAT:BoxCol> 
</AAT:BoxRow><%
}
foreach my $c (@{$columns})
{
	my $match = 0;
  foreach my $c2 (@{$Session->{order_by}})
  	{ $match = 1 if ($c2 eq $c); }
  if (! $match)
  {
%><AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$c" /></i></AAT:BoxCol>
  <AAT:BoxCol><AAT:Button name="add" link="$url?order_by_add=$c"/></AAT:BoxCol>
</AAT:BoxRow><%
	}
}
%>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
	<AAT:Selector name="sort_direction" list=\@list /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><b>Limit</b></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="limit" value="100" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="3">
  <AAT:Form_Submit value="_NEXT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
