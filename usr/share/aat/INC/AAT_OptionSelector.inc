<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %a = @_; 
my $selected = (AAT::NOT_NULL($a{selected}) ? "$a{selected} " : "");
%>
<option <%= "$selected" %>value="<%= $a{value} %>"<%= (AAT::NOT_NULL($a{style}) ? " style=\"$a{style}\"" : "") %>><%= $Server->HTMLEncode(AAT::Translation($a{label})) %></option>
