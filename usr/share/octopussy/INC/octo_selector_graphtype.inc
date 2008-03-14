<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $name = $arg{name} || "graph_type";
my @types = ( 
	{ label => "Array", value => "array" }, 
	{ label => "Horizontal Bars", value => "hbars" },
	{ label => "Pie", value => "pie" }, 
	{ label => "RRD Graph Lines", value => "rrd_line" },
	{ label => "RRD Graph Stacks", value => "rrd_stack" } );

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@types, selected => $arg{selected} );
%>
