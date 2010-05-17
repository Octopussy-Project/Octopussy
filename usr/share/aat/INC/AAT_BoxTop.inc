<%
my %arg = @_;
my $align = (defined $arg{align} ? 
	(($arg{align} =~ /^C/i) ? "center" 
		: (($arg{align} =~ /^R/i) ? "right" : $arg{align} )) : "left");
my $w = $arg{width};
my $bicolor = (defined $arg{bicolor} ? 1 : 0);
my $space = (NOT_NULL($arg{cellspacing}) ? $arg{cellspacing} : 0);
my $padd = (NOT_NULL($arg{cellpadding}) ? $arg{cellpadding} : 2);
%>
<!-- BoxTop -->
<div align="<%= $align %>">
<table cellspacing="0" cellpadding="0"<%= (defined $w ? " width=$w" : "") %>>
<tr>
<td class="box-top-left"></td>
<td class="boxtop"></td>
<td class="box-top-right"></td>
</tr>
<%
if ((defined $arg{icon}) || (defined $arg{title}))
{%>
	<tr><td class="box-left"></td>
	<td class="box">
	<div align="center" class="box">
	<table cellspacing="0" cellpadding="2">
	<tr>
		<td class="box"><AAT:IMG name="$arg{icon}" /></td>
		<td class="box"><AAT:Label value="$arg{title}" style="B" size="+1" /></td>
	</tr>
	</table>
	</div>
	</td>
	<td class="box-right"></td>
	</tr>
	<tr><td class="box-left"></td>
	<td class="box"><div class="box"><hr></div></td><td class="box-right"></td></tr><%
}%>
<tr>
<td class="box-left"></td>
<td class="box">
<table cellspacing="<%= $space %>" cellpadding="<%= $padd %>" width="100%">
