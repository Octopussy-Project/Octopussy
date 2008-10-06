<% 
my %arg = @_; 

my $options = "";
foreach my $k (keys %arg)
	{ $options .= " $k=\"$arg{$k}\""	if (($k ne "name") && ($k ne "data")); }
%>
<textarea name="<%= $arg{name} %>" <%= $options %>>
<% print $arg{data} %>
</textarea>
