<AAT:Box>
<%
my %arg = @_;

my $obj_conf = AAT::Object::Configuration($arg{object});
my $actions = (defined $arg{edit} ? 1 : 0) + (defined $arg{remove} ? 1 : 0);
my $cols = scalar(@{$obj_conf->{field}}) + $actions;
%>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="$cols">
	<AAT:Label value="$arg{object} List" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="$cols"><hr></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<%
foreach my $f (AAT::ARRAY($obj_conf->{field}))
{
	my $label = $f->{label};
	%><AAT:BoxCol><AAT:Label value="$label" style="B" /></AAT:BoxCol><%
}
if ($actions)
{
	%><AAT:BoxCol cspan="$actions">
	<AAT:Label value="_ACTION" style="B" /></AAT:BoxCol><%
}
%>
</AAT:BoxRow>
<AAT:BoxRow style="box">
	<AAT:BoxCol align="C" cspan="$cols"><hr></AAT:BoxCol>
</AAT:BoxRow>
<%
my $list = AAT::Object::Data($arg{object});

foreach my $c (AAT::ARRAY($list))
{
	%><AAT:BoxRow><%
	foreach my $f (AAT::ARRAY($obj_conf->{field}))
	{
		%><AAT:BoxCol><%= $c->{$f->{fid}} %></AAT:BoxCol><%
	}
	if (defined $arg{edit})
	{
		%><AAT:BoxCol align="C">
		<AAT:Button name="edit" tooltip="_EDIT" /></AAT:BoxCol><%
	}
	if (defined $arg{remove})
  {
    %><AAT:BoxCol align="C"><AAT:Button name="remove" tooltip="_REMOVE" />
    </AAT:BoxCol><%
  }
	%></AAT:BoxRow><%
}
%>
</AAT:Box>
