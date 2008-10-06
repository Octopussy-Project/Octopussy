<%
my %arg = @_;

my @plugins = Octopussy::Plugin::List();
%>
<AAT:Box align="C" title="Plugins">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
<AAT:BoxCol align="C" cspan="2">
<AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<%
foreach my $p (sort @plugins)
{
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$p" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Button name="edit" tooltip="_EDIT" 
		link="./plugin_edition.asp?plugin=$p" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Button name="info" tooltip="_INFORMATION" 
		link="./plugin_info.asp?plugin=$p" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
