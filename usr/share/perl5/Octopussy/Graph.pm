#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Graph - Octopussy Graph module

=cut
package Octopussy::Graph;

use strict;

use Octopussy;

use GD::Graph;
use GD::Graph::area;
use GD::Graph::bars;
use GD::Graph::colour;
use GD::Graph::hbars;
use GD::Graph::lines;
use GD::Graph::pie;
#use GD::Graph::Map;

my $TYPE = "bars";
my $WIDTH = 1024;
my $HEIGHT = 768;
my $LOGO = "";
my $LOGO_POSITION = "UR";
my $MARGIN = 20;

=head1 FUNCTIONS

=head2 Generate($g)

Generate graph

=cut 
sub Generate($$)
{
	my ($g, $output) = @_;

	$GD::Graph::Error::Debug = 5;

	$output = $output || "graph.png";
	my $fct = "GD::Graph::" . ($g->{type} || $TYPE);
	my $graph = $fct->new($g->{width} || $WIDTH, $g->{height} || $HEIGHT);

	$graph->set(bar_spacing => 3)	if ($g->{type} =~ /bars$/);
	$graph->set(start_angle => 180)	if ($g->{type} =~ /^pie$/);
	my @colors = GD::Graph::colour::colour_list(32); 
	#read_rgb("/etc/X11/rgb.txt");
	$graph->set(
	#x_label => ($g->{x_label} || "X Label"), 
	#y_label => ($g->{y_label} || "Y Label"), 
	title => $g->{title} || "",
	logo => $g->{logo} || $LOGO,
	logo_position => $g->{logo_position} || $LOGO_POSITION,
	#x_labels_vertical => 1,
	t_margin => $g->{margin} || $MARGIN, b_margin => $g->{margin} || $MARGIN, 
	l_margin => $g->{margin} || $MARGIN, r_margin => $g->{margin} || $MARGIN,
	#      y_max_value       => 8,
	#      y_tick_number     => 8,
	#      y_label_skip      => 2
	dclrs => \@colors
	) or die $graph->error;
	#$graph->set_legend($g->{data});
	my $gd = $graph->plot($g->{data}) or die $graph->error;
	open(IMG, "> $output") or die $!;
	binmode IMG;
	print IMG $gd->png;
	close(IMG);

	#my $map = new GD::Graph::Map($graph, newWindow => 1);
	#$map->set(info => "%x du total");
	#my $html = $map->imagemap("graph.png", $g->{data});

	#return ($html);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
