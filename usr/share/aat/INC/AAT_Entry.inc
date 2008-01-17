<% 
my %arg = @_; 

my $options = "";
foreach my $k (keys %arg)
 { $options .= " $k=\"$arg{$k}\""  if (($k ne "name") && ($k ne "value")); }
%>
<input type="text" name="<%= $arg{name} %>" 
<%= (defined $arg{value} ? " value=\"$arg{value}\"" : "") %> <%= $options %>>
