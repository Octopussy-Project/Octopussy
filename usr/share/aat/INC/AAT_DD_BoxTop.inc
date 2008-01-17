<%
my %arg = @_;

my $align = $arg{align} || "left";
my $w = $arg{width};
my $bicolor = (defined $arg{bicolor} ? 1 : 0);
%>
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
	<table cellspacing=0 cellpadding=2 width="100%">
	<AAT:BoxRow>
	<AAT:BoxCol align="right"><AAT:IMG name="$arg{icon}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$arg{title}" style="bold" size="+1" />
	</AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	</table>
	</td><td class="box-right"></td></tr><%
}%>
<tr>
<td class="box-left"></td>
<td class="box">
<table cellspacing=0 cellpadding=2 width="100%">
<div id="<%= $arg{id} %>" class="DD_Container">
