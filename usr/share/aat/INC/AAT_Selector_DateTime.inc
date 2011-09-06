<% 
my %arg = @_; 
my ($date, $time) = ($1, $2)
	if ($arg{selected} =~ /(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2})/);
%>
<table>
<tr>
<td><AAT:Selector_Date name="$arg{name}" selected="$date" 
	onchange="$arg{onchange}" /></td>
<td><AAT:Selector_Time name="$arg{name}" selected="$time" 
	onchange="$arg{onchange}" /></td>
</table>
