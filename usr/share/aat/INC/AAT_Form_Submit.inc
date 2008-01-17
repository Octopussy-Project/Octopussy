<% my %arg = @_; %>
<input type="submit" name="<%= $arg{name} %>" value="<%= AAT::Translation($arg{value} || "submit") %>">
