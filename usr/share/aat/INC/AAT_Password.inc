<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% my %arg = @_; %>
<input type="password" name="<%= $arg{name} %>" value="<%= $arg{value} %>" 
<%= (defined $arg{size} ? " size=\"$arg{size}\"" : "") %>
<%= (defined $arg{maxlength} ? " maxlength=\"$arg{maxlength}\"" : "") %>>
