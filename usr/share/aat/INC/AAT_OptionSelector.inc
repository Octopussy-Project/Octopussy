<% my %a = @_; %>
<option <%= $a{selected} %> value="<%= $a{value} %>"<%= (defined $a{style} ? " style=\"$a{style}\"" : "") %>><%= $Server->HTMLEncode(AAT::Translation($a{label})) %></option>
