<% 
my %arg = @_; 
use AAT;

if (AAT::NULL($Session->{AAT_LOGIN}))
{
  my $page = "./login.asp?redirect="
    . $Request->ServerVariables("REQUEST_URI");
  $Response->Redirect($page);
}
my $title = "Octopussy " . ($arg{title} || "");
%>
<AAT:PageTop title="$title" icon="IMG/octopussy.gif" onLoad="$arg{onLoad}"
  refresh="$arg{refresh}" close_popup="y" popup="y" tooltip="y" />
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td colspan="2">
<% $Response->Include('INC/octo_top_menu_restricted.inc') %></td></tr>
<tr><td valign="top">
<% $Response->Include('INC/octo_main_menu_restricted.inc') %></td>
<td valign="top" align="center">
<AAT:Msg_Error />
