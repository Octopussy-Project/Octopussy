<%
my %arg = @_;

my @colors = (
	"red", "green", "blue", "yellow", "orange", "brown", "gray", "cyan", 
	"magenta", "pink", "purple", "lightgreen", "lightblue",  );
%>
<select name="<%= $name || "color" %>">
<%
foreach my $c (@colors)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $c,
  	style => "color:$c",  selected => ($c == $arg{selected} ? "SELECTED" : ""), 
		label => $c );
}
%>
</select>
