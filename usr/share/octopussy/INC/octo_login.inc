<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my $version = "Octopussy " . Octopussy::Version();
my $website = Octopussy::WebSite(); 
%>
<AAT:Form method="POST" action="./login.asp">
<AAT:Box align="center" cellpadding="0">
<AAT:BoxRow valign="top">
	<AAT:BoxCol valign="top" rspan="4">
	<AAT:Picture file="IMG/octo_login1.png" alt="Octopussy Logo" /></AAT:BoxCol>
	<AAT:BoxCol valign="top">
	<AAT:Picture file="IMG/octo_login2.png" alt="Octopussy Logo" /></AAT:BoxCol>
	<AAT:BoxCol valign="top" align="R">
	<AAT:Help page="HELP/en/login.html" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
 	<AAT:BoxCol align="R"><AAT:Label value="_LOGIN" style="B" /></AAT:BoxCol>
 	<AAT:BoxCol><AAT:Entry name="login" value="" size="12" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Label value="_PASSWORD" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Password name="password" value="" size="12" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R">
	<AAT:Button name="web" link="$website" width="24" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_WEBSITE" link="$website" size="-1"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><AAT:Label value="$version" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="3">
 	<AAT:Form_Submit value="Connect to Octopussy" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
if (AAT::NOT_NULL(AAT::Msg_Error()))
{
	my $msg = AAT::Msg_Error();
	%><div align="center"><AAT:Label value="$msg" color="red" /></div><%
	AAT::Msg_Error("");
}
%>
