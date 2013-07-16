<%
my %arg = @_;

my $report = $arg{report};
foreach my $c (Octopussy::Report::Categories())
  { push(@categories, $c->{category}); }

my $conf = Octopussy::Report::Configuration($report);
my ($r_name, $r_desc) = ($conf->{name}, $Server->HTMLEncode($conf->{description}));
my ($r_cat, $r_type) = ($conf->{category}, $conf->{graph_type});
my ($r_table, $r_taxo, $r_loglevel) = ($conf->{table}, $conf->{taxonomy}, $conf->{loglevel});
my $r_query = $Server->HTMLEncode($conf->{query});
my ($r_cols, $r_colnames) = ($conf->{columns}, $conf->{columns_name});
my ($r_x, $r_y) = ($conf->{x}, $conf->{y});
%>
<AAT:Form action="./report_edit.asp">
<AAT:Form_Hidden name="old_report" value="$r_name" />
<AAT:Form_Hidden name="graph_type" value="$r_type" />
<AAT:Form_Hidden name="columns" value="$r_cols" />
<AAT:Form_Hidden name="columns_name" value="$r_colnames" />
<AAT:Form_Hidden name="x" value="$r_x" />
<AAT:Form_Hidden name="y" value="$r_y" />
<AAT:Form_Hidden name="modify" value="yes" />
<AAT:Box align="C" icon="buttons/bt_report" title="_REPORT_EDITION">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B"/> (only [-_a-zA-Z0-9] chars)</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="name" value="$r_name" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Entry name="description" value="$r_desc" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_CATEGORY" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="category" selected="$r_cat" list=\@categories />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_TYPE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$r_type" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_TABLE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_table" name="table" selected="$r_table" 
		onchange="refresh_selector_loglevel();refresh_selector_taxonomy();" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_LOG_LEVEL" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_loglevel_dynamic" name="loglevel" 
    selected="$r_loglevel" any="1" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_taxonomy_dynamic" name="taxonomy" 
		selected="$r_taxo" any="1" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_QUERY" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:TextArea name="query" cols="100" rows="3" wrap="on" data="$r_query" />
  </AAT:BoxCol>
</AAT:BoxRow>
<%
if ($r_type =~ /array/)
{
	my ($r_cols, $r_cols_name) = ($conf->{columns}, $conf->{columns_name});
%><AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_COLUMNS" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="columns" value="$r_cols" size="100" />
	</AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_COLUMNS_NAMES" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="columns_name" value="$r_cols_name" size="100" />
  </AAT:BoxCol>
	</AAT:BoxRow><%
}
elsif ($r_type =~ /^rrd_/)
{
	my ($r_timeline, $r_rrd_step, $r_ds1, $r_ds2, $r_ds3, $r_dsvalue) = 
		($conf->{timeline}, $conf->{rrd_step}, 
		$conf->{datasource1}, $conf->{datasource2}, 
		$conf->{datasource3}, $conf->{datasources_value});
	my ($g_title, $g_type, $g_ylabel, $g_width, $g_height) = 
		($conf->{graph_title}, $conf->{graph_type}, $conf->{graph_ylabel},
			$conf->{graph_width}, $conf->{graph_height});
%><AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TIMELINE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_timeline" name="rrd_timeline" 
		table="$r_table" selected="$r_timeline"  /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_TIMESTEP" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_rrdgraph_timestep" name="rrd_step"
  	selected="$r_rrd_step"  /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DATASOURCE" style="B"/><b>1</b></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_datasource" name="datasource1"
		table="$r_table" selected="$r_ds1" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DATASOURCE" style="B"/><b>2</b></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_datasource" name="datasource2"
    table="$r_table" selected="$r_ds2" none="1" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DATASOURCE" style="B"/><b>3</b></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_datasource" name="datasource3"
    table="$r_table" selected="$r_ds3" none="1" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DATASOURCE_VALUE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_rrdgraph_datasource_value" 
		name="datasources_value" table="$r_table" selected="$r_dsvalue"/>
	</AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_TITLE" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="graph_title" value="$g_title" size="50" />
  </AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GRAPH_Y_LABEL" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="graph_ylabel" value="$g_ylabel" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_WIDTH" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector_Number name="graph_width" 
		min="300" max="3000" step="50" selected="$g_width" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_HEIGHT" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>   <AAT:Selector_Number name="graph_height"
    min="200" max="2000" step="50" selected="$g_height" /></AAT:BoxCol>
  </AAT:BoxRow><%
}
elsif ($r_type =~ /rrd/)
{
  my ($r_x, $r_y) = ($conf->{x}, $conf->{y});
%><AAT:BoxRow>
  <AAT:BoxCol align="R"><b>X</b></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="x" value="$r_x" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol align="R"><b>Y</b></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="y" value="$r_y" size="50" />
  </AAT:BoxCol>
  </AAT:BoxRow>
<%
}%>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
