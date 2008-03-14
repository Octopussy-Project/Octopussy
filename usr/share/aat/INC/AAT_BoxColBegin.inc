<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %a = @_; 
my $align = (defined $a{align} ? ($a{align} =~ /^C$/i ? " align=\"center\" " 
	: ($a{align} =~ /^R$/i ? " align=\"right\" " : " align=\"$a{align}\" " )) : "");
%>
<td class="box"<%= $align %><%= (defined $a{valign} ? " valign=\"$a{valign}\"" : "") %><%= (defined $a{cspan} ? " colspan=\"$a{cspan}\"" : "") %><%= (defined $a{rspan} ? " rowspan=\"$a{rspan}\"" : "") %><%= (defined $a{width} ? " width=\"$a{width}\"" : "")%>>
