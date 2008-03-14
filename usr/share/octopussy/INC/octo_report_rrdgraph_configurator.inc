<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $table = $Session->{table};
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="C" title="_REPORT_RRD_GRAPH_CREATION" icon="buttons/bt_report">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TIMELINE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_timeline" table="$table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_TIMESTEP" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_timestep" table="$table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DATASOURCES" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_rrdgraph_datasource" 
	name="datasource1" table="$table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_rrdgraph_datasource"   
	name="datasource2" none="1" table="$table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_rrdgraph_datasource" 
	name="datasource3" none="1" table="$table" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DATASOURCES_VALUE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_rrdgraph_datasource_value" table="$table" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_TITLE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="graph_title" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_Y_LABEL" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="graph_ylabel" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_WIDTH" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector_Number name="graph_width" min="300" max="3000" 
		step="50" selected="800" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_HEIGHT" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector_Number name="graph_height" min="200" max="2000"
		step="50" selected="600" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_CREATE_REPORT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
