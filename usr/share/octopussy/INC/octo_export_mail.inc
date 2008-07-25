<% my %arg = @_; %>
<AAT:Box width="$arg{width}">
<AAT:BoxRow>
  <AAT:BoxCol cspan="5">
	<AAT:Label value="_EXPORT_MAIL" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol rspan="2"><AAT:IMG name="generic_mail" /></AAT:BoxCol>
<%
my ($level, $msg) = ((AAT::SMTP::Connection_Test("Octopussy"))
	? (0, "SMTP Connection is OK !") : (2, "SMTP Connection is NOT OK !"));
if ($level != 0)
{
	%><AAT:BoxCol rspan="2">
	<AAT:Message level="1" msg="$msg" link="./system.asp" />
	</AAT:BoxCol><%
}
else
{
%><AAT:BoxCol align="R" rspan="2">
	<AAT:Label value="_RECIPIENTS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol rspan="2">
	<AAT:Inc file="octo_selector_contact" name="mail_recipients" 
		size="5" multiple="1"/></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_SUBJECT" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="mail_subject" size="40"/></AAT:BoxCol><%
} %>
</AAT:BoxRow>
</AAT:Box>
