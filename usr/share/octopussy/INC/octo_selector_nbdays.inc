<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my $name = $arg{name} || "number";
my $min = $arg{min} || 0;
my $max = $arg{max} || 10;
my $selected = $arg{selected} || "";
my $step = $arg{step} || 1;
%>
<select name="<%= $name %>">
<%
my $i = $min;
while ($i <= $max)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $i,
    selected => ($i == $selected ? "SELECTED" : ""), 
		label => "$i " . AAT::Translation("_DAYS"));
	$i += $step;
}
%>
</select>
