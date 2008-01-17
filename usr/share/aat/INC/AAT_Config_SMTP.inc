<%
my %arg = @_;
my $tt = $arg{tooltip};
my $smtp = AAT::SMTP::Configuration();
my ($server, $sender) = ($smtp->{server}, $smtp->{sender});
%>
<AAT:Box width="100%">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="SMTP" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="smtp_server" value="$server" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="2"><AAT:IMG name="generic_mail" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
	<AAT:Label value="_SENDER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="smtp_sender" value="$sender" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<%
if (AAT::NOT_NULL($server))
{
	my ($level, $msg) = ((AAT::SMTP::Connection_Test()) 
		? (0, "SMTP Connection is OK !") : (2, "SMTP Connection is NOT OK !"));
%>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"><AAT:Message level="$level" msg="$msg" /></AAT:BoxCol>
</AAT:BoxRow>
<%
}
%>
</AAT:Box>
