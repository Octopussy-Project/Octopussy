<%
my %arg = @_;
my $button = ($arg{level} == 2 ? "msg_critical" 
	: ($arg{level} == 1 ? "msg_warning" 
	: ($arg{level} == -1 ? "info" : "msg_ok")));
my $color = ($arg{level} == 2 ? "red" 
	: ($arg{level} == 1 ? "orange" 
	: ($arg{level} == -1 ? "blue" : "green")));
%>
<table>
<tr valign="middle">
<td><AAT:Button name="$button" /></td>
<td><AAT:Label value="$arg{msg}" color="$color" /></td>
</tr>
</table>
