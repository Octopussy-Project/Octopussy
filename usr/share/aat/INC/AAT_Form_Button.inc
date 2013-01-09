<% 
my %arg = @_; 
my $src = "AAT/IMG/buttons/bt_" . $arg{name} . ".png";
my $value = $arg{value};

if ((defined $arg{name}) && (-f $src))
{
	my $tooltip = AAT::Translation($arg{tooltip} || "");
	$tooltip =~ s/'/\\'/g if (defined $tooltip);
	my $twidth = (defined $tooltip ? ((length($tooltip) < 50) ? length($tooltip)*8 : 400) : 0);
	my $str_tooltip = (NOT_NULL($tooltip) ?
	  "<div onMouseover=\"tooltip('" . $tooltip . "', " . $twidth . ")\"; onMouseout=\"hidetooltip()\">" : "");
	my $str_tooltip_end = (NOT_NULL($tooltip) ? "</div>" : "");
  %>
	<%= $str_tooltip %><button name="<%= $value %>" value="<%= $value %>"><img src="<%= $src %>" alt="[<%= $value %>]" /></button>
	<%= $str_tooltip_end %><%
}
%>
