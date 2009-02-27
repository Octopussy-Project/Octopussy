<%
my %arg = @_;
my $name = $arg{name} || "graph_type";
my @types = ( 
	{ label => "Array", value => "array" }, 
  { label => "OFC Area Hollow", value => "ofc_area_hollow" },
  { label => "OFC Bar 3D", value => "ofc_bar_3d" },
  { label => "OFC Bar Cylinder", value => "ofc_bar_cylinder" },
  { label => "OFC Bar Glass", value => "ofc_bar_glass" },
  { label => "OFC Bar Sketch", value => "ofc_bar_sketch" },
	{ label => "OFC Horizontal Bar", value => "ofc_hbar" },
	{ label => "OFC Pie", value => "ofc_pie" }, 
	{ label => "RRD Graph Lines", value => "rrd_line" },
	{ label => "RRD Graph Stacks", value => "rrd_stack" } );

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@types, selected => $arg{selected} );
%>
