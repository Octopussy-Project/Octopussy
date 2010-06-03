<% 
my %a = @_; 
my $selected = (NOT_NULL($a{selected}) ? "$a{selected} " : "");
%>
<option <%= "$selected" %>value="<%= $a{value} %>"<%= (NOT_NULL($a{style}) ? " style=\"$a{style}\"" : "") %>><%= $Server->HTMLEncode($a{label}) %></option>
