<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %args = @_;

my @functions = Octopussy::Plugin::Functions();
my $plugin = $args{plugin};
%>
<AAT:Box align="C" title="'$plugin' Plugin Edition">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_PERL_FUNCTION" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_SOURCE" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<%
foreach my $func (@functions)
{
	if ($func->{plugin} eq $plugin)
	{
		foreach my $f (@{$func->{functions}})
		{
			my ($label, $perl, $data_source) = 
				($f->{label}, $f->{perl}, $f->{source});
		%><AAT:BoxRow>
		<AAT:BoxCol><AAT:Label value="$label" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$perl" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$data_source" /></AAT:BoxCol>
		</AAT:BoxRow><%
		}
	}
}
%>
</AAT:Box>
