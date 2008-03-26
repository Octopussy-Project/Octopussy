<%
my %arg = @_;
my $align = (defined $arg{align} ? 
	(($arg{align} =~ /^C/i) ? "center" 
		: (($arg{align} =~ /^R/i) ? "right" : $arg{align} )) : "left");
my $w = $arg{width};
my $bicolor = (defined $arg{bicolor} ? 1 : 0);
my $cellspacing = (AAT::NOT_NULL($arg{cellspacing}) ? $arg{cellspacing} : 0);
my $cellpadding = (AAT::NOT_NULL($arg{cellpadding}) ? $arg{cellpadding} : 2);
%>
<!-- BoxTop -->
<div align="<%= $align %>">
<table cellspacing=0 cellpadding=0<%= (defined $w ? " width=$w" : "") %>>
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
	<table cellspacing="0" cellpadding="2" width="100%">
	<AAT:BoxRow>
	<AAT:BoxCol align="right"><AAT:IMG name="$arg{icon}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$arg{title}" style="B" size="+1" />
	</AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	</table>
	</td><td class="box-right"></td></tr><%
}%>
<tr>
<td class="box-left"></td>
<td class="box">
<table cellspacing="<%= $cellspacing %>" cellpadding="<%= $cellpadding %>" 
	width="100%">
