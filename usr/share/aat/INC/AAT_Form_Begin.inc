<% my %arg = @_; %>
<form name="<%= ($arg{name} || "unknown") %>" method="<%= ($arg{method} || "POST") %>" action="<%= $arg{action} %>">
