<% 
my %arg = @_; 

my @list = ( { label => AAT::Translation("_UNKNOWN"), value => "Unknown" } );

foreach my $c (sort (Octopussy::Location::Cities()))
{
	push(@list, { label => "$c", value => "$c" });
  	foreach my $b (sort (Octopussy::Location::Buildings($c)))
  	{
		push(@list, { label => "$c - $b", value => "$c,$b" });
    	foreach my $r (sort (Octopussy::Location::Rooms($c, $b)))
    	{
			push(@list, { label => "$c - $b - $r", value => "$c,$b,$r" });
      		foreach my $rack (sort (Octopussy::Location::Racks($c, $b, $r)))
      		{
				push(@list, { label => "$c - $b - $r - $rack", 
					value => "$c,$b,$r,$rack" });
			}
		}
	}
}
%>
<AAT:Selector name="location" selected="$arg{selected}" list=\@list />
