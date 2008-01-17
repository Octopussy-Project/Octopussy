<% 
my %arg = @_; 
my ($selected_hour, $selected_min) = split(/:/, $arg{selected});
my @ltime = localtime(time);
my ($min, $hour) = ($selected_min || $ltime[1], $selected_hour || $ltime[2]);
my @hours = ();
my @mins = ();
my $step = $arg{step} || 1;
foreach my $i (0..23)
	{ push(@hours, ($i < 10 ? "0" . $i : $i)); }
my $i = 0;
while ($i <= 59)
{
	push(@mins, ($i < 10 ? "0" . $i : $i));
	$i += $step;
}
%>
<table>
<tr><td>
<% $Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{name} . "_hour", list => \@hours, selected => $hour); %>
</td><td>
<% $Response->Include('AAT/INC/AAT_Selector.inc',
  name => $arg{name} . "_min", list => \@mins, selected => $min); %>
</td></tr>
</table>
