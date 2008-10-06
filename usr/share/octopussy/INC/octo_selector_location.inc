<% 
my %arg = @_; 
foreach my $c (sort (Octopussy::Location::Cities()))
{
  foreach my $b (sort (Octopussy::Location::Buildings($c)))
  {
    foreach my $r (sort (Octopussy::Location::Rooms($c, $b)))
    {
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
