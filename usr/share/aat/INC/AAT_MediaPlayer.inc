<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my $status = "pause";
%>
<AAT:Box>
<AAT:BoxRow>
<AAT:BoxCol><AAT:Button name="player_start" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Button name="player_rew" /></AAT:BoxCol>
<%
if ($status ne "stop")
	{ %><AAT:BoxCol><AAT:Button name="player_stop" /></AAT:BoxCol><% }
if ($status ne "pause")
	{ %><AAT:BoxCol><AAT:Button name="player_pause" /></AAT:BoxCol><% }
if ($status ne "play")
	{ %><AAT:BoxCol><AAT:Button name="player_play" /></AAT:BoxCol><% }
%>
<AAT:BoxCol><AAT:Button name="player_fwd" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Button name="player_end" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
