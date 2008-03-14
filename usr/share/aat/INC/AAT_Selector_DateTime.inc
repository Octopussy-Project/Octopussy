<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my ($d,$m,$y,$hour,$min) = ($1, $2, $3, $4, $5)
	if ($arg{selected} =~ /(\d+)\/(\d+)\/(\d+)\/(\d+)\/(\d+)/);
%>
<table>
<tr>
<td><AAT:Selector_Date name="$arg{name}" start_year="$arg{start_year}" 
	selected="$d/$m/$y" onchange="$arg{onchange}" /></td>
<td><AAT:Selector_Time name="$arg{name}" selected="$hour:$min" 
onchange="$arg{onchange}" /></td>
</table>
