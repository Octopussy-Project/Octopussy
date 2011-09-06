<% 
my %arg = @_; 

my $options = "";
foreach my $k (keys %arg)
 { $options .= " $k=\"$arg{$k}\""  if (($k ne "name") && ($k ne "value")); }
my $value = $arg{value};
$value =~ s/"/&quot;/g;
%>
<input type="text" id="<%= $arg{name} %>" name="<%= $arg{name} %>" 
<%= (defined $value ? " value=\"$value\"" : "") %> <%= $options %>>
