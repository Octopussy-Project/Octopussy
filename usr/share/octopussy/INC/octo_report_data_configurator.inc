<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @categories = ();
foreach my $c (Octopussy::Report::Categories())
	{ push(@categories, $c->{category}); }
push(@categories, "base")	if ($#categories < 0);			
%>
<AAT:Form action="$arg{url}">
<AAT:Box icon="buttons/bt_report" title="_REPORT_CREATION">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TITLE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Entry name="title" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Entry name="description" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_CATEGORY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="new_category" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector name="category" selected="$arg{category}" list=\@categories />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GRAPH_TYPE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Inc file="octo_selector_graphtype" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Inc file="octo_selector_table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Inc file="octo_selector_taxonomy" any="1" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="3" align="C"><AAT:Form_Submit value="_NEXT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
