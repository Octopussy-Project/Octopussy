<% my %arg = @_; %>
<input type="CHECKBOX" name="<%= "$arg{name}" %>" <%= ($arg{selected} ? "checked" : "") %>>
