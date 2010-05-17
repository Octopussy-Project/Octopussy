<% my %arg = @_; %>
<select <%= (defined $arg{multiple} ? "multiple " : "") %> <%= (defined $arg{size} ? "size=$arg{size} " : "") %> name="<%= (defined $arg{name} ? $arg{name} : "device" ) %>"
  onchange="location = '<%= $arg{url} %>' + this.options[this.selectedIndex].value;">
<%
my $list = $arg{list};
foreach my $e (ARRAY($list))
{
	%><option value="<%= $e %>"<%= $arg{selected} eq $e ? " selected" : "" %>>
	<%= AAT::Translation($e) %></option><% 
} %>
</select>
