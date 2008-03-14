<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $login = $Session->{AAT_LOGIN};
my $logout_lnk = "./dialog.asp?id=logout";
my $version = "Octopussy " . Octopussy::Version(); 
my $lang = lc($Session->{AAT_LANGUAGE} || "en");
my $help_lnk = $arg{help} || "index";
$lang = (-f "HELP/$lang/${help_lnk}.html" ? $lang : "en");
%>
<AAT:Box width="100%">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Button name="user_prefs" tooltip="_USER_PREFS" link="./user_pref.asp"/>
  </AAT:BoxCol>
	<AAT:BoxCol width="100%" align="C">
	<AAT:Label value="$version" style="B" link="./index.asp" /><br>
	<AAT:Label value="_USER" /><%= ": $login" %>
	</AAT:BoxCol>	
	<AAT:BoxCol><AAT:Help page="HELP/$lang/${help_lnk}.html" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Button name="exit" tooltip="_LOGOUT" popup_link="$logout_lnk"/>
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
