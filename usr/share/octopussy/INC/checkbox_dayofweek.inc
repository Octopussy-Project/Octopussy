<% 
my %arg = @_; 
my @weekdays = (
	{ label => "_MONDAY", value => "Monday" }, 
	{ label => "_TUESDAY", value => "Tuesday" }, 
	{ label => "_WEDNESDAY", value => "Wednesday" }, 
	{ label => "_THURSDAY", value => "Thursday" }, 
	{ label => "_FRIDAY", value => "Friday" }, 
	{ label => "_SATURDAY", value => "Saturday" }, 
	{ label => "_SUNDAY", value => "Sunday" }, 
	{ label => "_EVERY_DAY", value => "Every Day" } );
%>
<table>
<tr><td>
<% $Response->Include('AAT/INC/AAT_CheckBox_List.inc',
		name => $arg{name}, list => \@weekdays, max_cols => 4);
%>
</td></tr>
</table>
