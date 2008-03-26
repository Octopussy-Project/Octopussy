<% 
use utf8;
my %arg = @_; 
my $style = $arg{style};
my $color = $arg{color};
my $size = $arg{size};
my $lnk = $arg{link};
my $lnk_new = $arg{link_new};
my $popup = $arg{popup_link};
my $tooltip = AAT::Translation($arg{tooltip});
my $close = $arg{close_popup_link};

my $s_style = (defined $style 
	? ((($style eq "bold") || ($style =~ /B/i)) ? "<b>" : "") : "");
my $s_style_end = 
	(defined $style 
	? ((($style eq "bold") || ($style =~ /B/i)) ? "</b>" : "") : "");
my $s_color = (defined $color ? "<font color='$arg{color}'>" : "");
my $s_color_end = (defined $color ? "</font>" : "");
my $s_size = (defined $size ? "<font size='$arg{size}'>" : "");
my $s_size_end = (defined $size ? "</font>" : "");
my $str_label = (defined $arg{no_trans} ? $arg{value} 
	: AAT::Translation($arg{value}));

my $str_link = (defined $lnk ? "<a href=\"$lnk\">" :
	(defined $lnk_new ? "<a href=\"$lnk_new\" target=\"_blank\">" :
	(defined $popup ? "<a href=\"$popup\" onClick=\"return popup(this, 'popup')\">" :
	(defined $close ? "<a href=\"$close\" onClick=\"return targetopener(this,true)\">" :
	""))));
my $str_link_end = ((defined $lnk || defined $lnk_new || defined $popup || defined $close) ? "</a>" : ""); 
my $str_tooltip = (defined $tooltip ? 
	"<div onMouseover=\"tooltip('" . $tooltip . "', 400)\"; onMouseout=\"hidetooltip()\">" : "");
my $str_tooltip_end = (defined $tooltip ? "</div>" : "");

print $s_style . $s_color . $s_size . $str_link . $str_tooltip . $str_label . 
$str_tooltip_end . $str_link_end . $s_size_end . $s_color_end . $s_style_end;
%>
