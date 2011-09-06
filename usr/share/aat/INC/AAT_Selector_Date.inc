<% 
my %arg = @_; 
my $lang = lc($Session->{AAT_LANGUAGE});
$lang =~ s/en/en-GB/g;
my @ltime = localtime(time);
my ($day, $month, $year) = ($ltime[3], $ltime[4] + 1, $ltime[5] + 1900);
my $value = (($arg{selected} && $arg{selected} ne '') ? $arg{selected} 
	: sprintf("%04d-%02d-%02d", $year, $month, $day));
%>
<table>
<tr><td><input id="<%= $arg{name} %>_date" name="<%= $arg{name} %>_date" type="text" size="10" value="<%= $value %>"></td></tr>
</table>
<script type="text/javascript">
$(function() {
		$("#<%= $arg{name} %>_date").datepicker($.datepicker.regional["<%= $lang %>"]);
		$("#<%= $arg{name} %>_date").datepicker("option", { 
			dateFormat: 'yy-mm-dd',
			changeMonth: true, changeYear: true, 
			showOtherMonths: true, selectOtherMonths: true,
			showWeek: true, firstDay: 1,
			showAnim: 'slideDown',
			} );
		$("#<%= $arg{name} %>_date").datepicker("option", "currentText", "<%= $value %>");
	});
</script>
