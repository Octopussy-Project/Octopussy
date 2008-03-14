<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Bug Report" />
<%
my $f = $Request->Form();
my $email = Octopussy::Email();

if (AAT::NOT_NULL($f->{file}))
{
	AAT::SMTP::Send_Message_With_File("Octopussy",
		AAT::Translation("_MSG_THIS_IS_MY_NEW"),
		$f->{comment}, $f->{file}, $email);
	%><div align="center"><AAT:Label value="_MSG_MAIL_SENT_TO_SUPPORT" /></div><%
}
%>
<AAT:Inc file="octo_submit_to_devel" />
<WebUI:PageBottom />
