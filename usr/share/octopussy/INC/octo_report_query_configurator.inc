<%
my %arg = @_;
my $url = $arg{url};
my $table = $Session->{table};
my @list = ("ASCENDING", "DESCENDING");
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
  <AAT:BoxCol align="R"><AAT:Label value="Select" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Inc file="octo_selector_query_select" name="select" table="$table" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Label value="Where" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Entry name="where" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Label value="Group By" style="B" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="group_by" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Label value="Order By" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="order_by" size="24" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector name="sort_direction"	list=\@list /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Label value="Limit" style="B" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="limit" value="100" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="3">
	<AAT:Form_Submit value="_NEXT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
