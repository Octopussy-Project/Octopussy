<% 
my %arg = @_; 
my @list = ();
foreach my $i (1..31)
	{ push(@list, ($i < 10 ? "0" . $i : $i)); }
%>
<table>
<tr><td><% $Response->Include('AAT/INC/AAT_CheckBox_List.inc',
						name => $arg{name}, list => \@list, max_cols => 11); %></td></tr>
</table>
