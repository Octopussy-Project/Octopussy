<% 
my %arg = @_; 
my $name = $arg{name} || "submit";
my $value = AAT::Translation($arg{value} || "submit");

if (AAT::NOT_NULL($arg{btname}))
{
%><input type="image" name="<%= $name %>" 
	src="AAT/IMG/buttons/bt_<%= $arg{btname} %>.png" value="<%= $value %>"><%
}
else
	{ %><input type="submit" name="<%= $name %>" value="<%= $value %>"><% }
%>
