<% 
my %a = @_; 
my $align = (defined $a{align} ? ($a{align} =~ /^C$/i ? "center" : ($a{align} =~ /^R$/i ? "right" : $a{align} )) : "left");
%>
<td class="box" align="<%= $align %>"<%= (defined $a{valign} ? " valign=\"$a{valign}\"" : "") %><%= (defined $a{cspan} ? " colspan=\"$a{cspan}\"" : "") %><%= (defined $a{rspan} ? " rowspan=\"$a{rspan}\"" : "") %><%= (defined $a{width} ? " width=\"$a{width}\"" : "")%>>
