<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my @months = (
	{ label => "_JANUARY", value => "January" }, 
	{ label => "_FEBRUARY", value => "February" }, 
	{ label => "_MARCH", value => "March" }, 
	{ label => "_APRIL", value => "April" }, 
	{ label => "_MAY", value => "May" }, 
	{ label => "_JUNE", value => "June" },
	{ label => "_JULY", value => "July" }, 
	{ label => "_AUGUST", value => "August" }, 
	{ label => "_SEPTEMBER", value => "September" }, 
	{ label => "_OCTOBER", value => "October" }, 
	{ label => "_NOVEMBER", value => "November" }, 
	{ label => "_DECEMBER", value => "December" }, 
	{ label => "_EVERY_MONTH", value => "Every Month" } ); 
%>
<table>
<tr>
<td>
<% $Response->Include('AAT/INC/AAT_CheckBox_List.inc',
		name => $arg{name}, list => \@months, max_cols => 4);
%>
</td>
</tr>
</table>
