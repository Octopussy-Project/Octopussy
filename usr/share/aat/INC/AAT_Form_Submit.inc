<% my %arg = @_; 
if (AAT::NOT_NULL($arg{btname}))
{
%><input type="image" name="<%= $arg{name} %>" src="AAT/IMG/buttons/bt_<%= $arg{btname} %>.png" value="<%= AAT::Translation($arg{value} || "submit") %>"><%
}
else
{
%><input type="submit" name="<%= $arg{name} %>" value="<%= AAT::Translation($arg{value} || "submit") %>"><%
}
%>
