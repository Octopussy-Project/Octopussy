<% 
my %arg = @_; 

if ((defined $arg{file}) && (-f $arg{file}))
{
	my $href = "";
	my $tooltip = AAT::Translation($arg{tooltip});
	my $twidth = (defined $tooltip ? ((length($tooltip) < 50) ? length($tooltip)*8 : 400) : 0);
	my $str_tooltip = (AAT::NOT_NULL($tooltip) ?
	  "<div onMouseover=\"tooltip('" . $tooltip . "', " . $twidth . ")\"; onMouseout=\"hidetooltip()\">" : "");
	my $str_tooltip_end = (AAT::NOT_NULL($tooltip) ? "</div>" : "");
  my $width = (defined $arg{width} ? " width='$arg{width}'" : "");
  my $height = (defined $arg{height} ? " height='$arg{height}'" : "");
	my $alt = (defined $arg{alt} ? " alt=\"$arg{alt}\"" : "");
  my $href = (defined $arg{link} ? "<a href=\"$arg{link}\">"
		: (defined $arg{link_new}
 		? "<a href=\"$arg{link_new}\" target=\"_blank\">"
    : (defined $arg{popup_link}
    ? "<a href=\"$arg{popup_link}\" onClick=\"return popup(this, 'popup')\">"
    : (defined $arg{close_popup_link} ? "<a href=\"$arg{close_popup_link}\" onClick=\"return targetopener(this,true)\">"
    : "" ))));
  %>
	<%= $str_tooltip . $href %><img border="0" src="<%= $arg{file} %>"<%= $width %><%= $height %><%= $alt %>><%= ($href ne "" ? "</a>" : "") . $str_tooltip_end %><%
}
%>
