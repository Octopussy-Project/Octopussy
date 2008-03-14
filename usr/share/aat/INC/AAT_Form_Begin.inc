<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% my %arg = @_; %>
<form name="<%= ($arg{name} || "form") %>" method="<%= ($arg{method} || "POST") %>" action="<%= $arg{action} %>">
