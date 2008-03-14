<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

$Response->Include("AAT/INC/AAT_Picture.inc", file => "AAT/IMG/$arg{name}.png", 
	width => $arg{width}, height => $arg{height}, 
	tooltip => $arg{tooltip}, link => $arg{link}, link_new => $arg{link_new},
  popup_link => $arg{popup_link}, close_popup_link => $arg{close_popup_link},
  alt => $arg{alt});
%>
