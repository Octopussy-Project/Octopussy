<% 
my %arg = @_;
$Response->Include("AAT/INC/AAT_Picture.inc", 
	file => "AAT/IMG/buttons/bt_$arg{name}.png", tooltip => $arg{tooltip},
	alt => $arg{alt}, width => $arg{width}, height => $arg{height},
	link => $arg{link}, link_new => $arg{link_new},
	popup_link => $arg{popup_link}, close_popup_link => $arg{close_popup_link}); 
%> 
