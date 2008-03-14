<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

use AAT;

$Response->Redirect("./login.asp") if (AAT::NULL($Session->{AAT_LOGIN}));
%>
<AAT:PageTop title="Octopussy $arg{title}" icon="IMG/octopussy.gif"
  refresh="$arg{refresh}" close_popup="y" popup="y" tooltip="y" />
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td colspan="2">
<% $Response->Include('INC/octo_top_menu_restricted.inc') %></td></tr>
<tr><td valign="top">
<% $Response->Include('INC/octo_main_menu_restricted.inc') %></td>
<td align="center">
<AAT:Msg_Error/>
