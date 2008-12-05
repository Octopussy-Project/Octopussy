<%
my $url = "http://sourceforge.net/tracker/?func=add&group_id=154314";
%>
<WebUI:PageTop title="_BUG_REPORT" />
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol rspan="3"><AAT:IMG name="generic_bug" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Label value="_BUG_REPORT" link="$url&atid=791284"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C">
	<AAT:Label value="_FEATURE_REQUEST" link="$url&atid=791287"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C">
	<AAT:Label value="_SUPPORT_REQUEST" link="$url&atid=791285"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="_MSG_SUBMIT_TO_IMPROVE" link="./submit.asp"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="_MSG_CONTACT_ME" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
