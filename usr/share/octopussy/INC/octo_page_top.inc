<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
use AAT;

$Response->Redirect("./login.asp")    
	if ((AAT::NULL($Session->{AAT_LOGIN})) 
		|| ($Session->{AAT_ROLE} eq "restricted"));

my $title = "Octopussy " . ($arg{title} || "");
if (defined $arg{refresh})
{
  %><AAT:PageTop title="$title" icon="IMG/octopussy.gif"
  refresh="$arg{refresh}" close_popup="y" popup="y" tooltip="y" /><%
}
else
{
  %><AAT:PageTop title="$title" icon="IMG/octopussy.gif"
  close_popup="y" popup="y" tooltip="y" /><%
}%>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td colspan="2"><% $Response->Include('INC/octo_top_menu.inc', help => $arg{help}) %></td></tr>
<tr>
<td valign="top"><% $Response->Include('INC/octo_main_menu.inc') %></td>
<td align="center" width="*">
<AAT:Msg_Error/>
