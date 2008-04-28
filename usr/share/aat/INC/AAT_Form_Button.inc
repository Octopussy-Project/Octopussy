<% 
my %arg = @_; 
my $src = "AAT/IMG/buttons/bt_" . $arg{name} . ".png";
my $value = $arg{value};

if ((defined $arg{name}) && (-f $src))
{
	my $tooltip = AAT::Translation($arg{tooltip} || "");
	$tooltip =~ s/'/\\'/g if (defined $tooltip);
	my $twidth = (defined $tooltip ? ((length($tooltip) < 50) ? length($tooltip)*8 : 400) : 0);
	my $str_tooltip = (AAT::NOT_NULL($tooltip) ?
	  "<div onMouseover=\"tooltip('" . $tooltip . "', " . $twidth . ")\"; onMouseout=\"hidetooltip()\">" : "");
	my $str_tooltip_end = (AAT::NOT_NULL($tooltip) ? "</div>" : "");
  %>
	<%= $str_tooltip %><input type="image" src="<%= $src %>"
  value="<%= $value %>" alt="[<%= $value %>]" name="<%= $value %>">
	<%= $str_tooltip_end %><%
}
%>
