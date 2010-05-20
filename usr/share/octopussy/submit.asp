<WebUI:PageTop title="Bug Report" />
<%
my $f = $Request->Form();
my $email = Octopussy::Info::Email();

if (NOT_NULL($f->{file}))
{
	AAT::SMTP::Send_Message("Octopussy", { from => $f->{from}, 
    subject => AAT::Translation("_MSG_THIS_IS_MY_NEW"), body => $f->{comment}, 
    file => $f->{file}, dests => [ $email ] });
	%><div align="center"><AAT:Label value="_MSG_MAIL_SENT_TO_SUPPORT" /></div><%
}
%>
<AAT:Inc file="octo_submit_to_devel" />
<WebUI:PageBottom />
