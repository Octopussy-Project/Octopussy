<WebUI:PageTop title="RRD Data Manipulation" />
<%
my $report_type = $Request->QueryString("report_type");
my $filename = $Request->QueryString("filename");
my $dir_reports = Octopussy::Directory("data_reports");
my $file = "$dir_reports/$report_type/$filename";
my $rconf = Octopussy::Report::Configuration($report_type);
my ($r_title, $r_ylabel, $r_rrd_step, $r_graph_width, $r_graph_height) = 
	($rconf->{graph_title},  $rconf->{graph_ylabel}, $rconf->{rrd_step}, 
	$rconf->{graph_width}, $rconf->{graph_height});
my $nb_ds = Octopussy::RRDTool::DS_Count($file);
$file =~ s/rrd$/png/;
%>
<AAT:Form action="./rrd_data_manipulation.asp">
<AAT:Box align="C" icon="buttons/bt_report" title="RRD Data Manipulation">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GRAPH_TITLE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="graph_title" value="$r_title" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GRAPH_Y_LABEL" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Entry name="graph_ylabel" value="$r_ylabel" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_TIMESTEP" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_rrdgraph_timestep" selected="$r_rrd_step"/>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GRAPH_WIDTH" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_Number name="graph_width" 
		min="300" max="3000" step="50" selected="$r_graph_width" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GRAPH_HEIGHT" style="B"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_Number name="graph_height"
		min="200" max="2000" step="50" selected="$r_graph_height" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
for $i (1..$nb_ds)
{
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="DS$i" value="DS$i" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector_Color name="DS$i_color" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2">
	<img src="./img_report.asp?file=<%= "$file" %>"></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<WebUI:PageBottom />
