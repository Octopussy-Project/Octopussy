<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $logo = undef;

foreach my $e (AAT::List::Items($arg{list}))
	{ $logo = $e->{logo}	if ($arg{name} =~ /^$e->{value}$/);	}

if (defined $logo)
{
	$Response->Include("AAT/INC/AAT_Picture.inc", file => "AAT/IMG/${logo}.png", 
		width => $arg{width}, height => $arg{height}, 
		tooltip => $arg{tooltip}, link => $arg{link}, link_new => $arg{link_new},
  	popup_link => $arg{popup_link}, close_popup_link => $arg{close_popup_link},
  	alt => $arg{alt});
}
%>
