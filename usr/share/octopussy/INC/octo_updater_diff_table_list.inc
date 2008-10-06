<% my %arg = @_; %>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_FIELD" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_TYPE" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<%
foreach my $m (Octopussy::Table::Updates_Diff($arg{table}))
{
	print "$m->{title}, $m->{type}<br>";
	my ($title, $type) = ($m->{title}, $m->{type});
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$title" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
