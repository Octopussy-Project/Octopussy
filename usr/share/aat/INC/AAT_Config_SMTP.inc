<%
my %arg = @_;
my $tt = $arg{tooltip};
my $smtp = AAT::SMTP::Configuration($arg{appli});
my ($server, $sender, $auth_type, $auth_login, $auth_password) = 
	($smtp->{server}, $smtp->{sender}, $smtp->{auth_type}, 
	$smtp->{auth_login}, $smtp->{auth_password});
my @auth_types = qw(-NONE- LOGIN PLAIN CRAM-MD5 NTLM);
%>
<AAT:Box width="100%">
<AAT:Form method="POST" action="$arg{action}">
<AAT:Form_Hidden name="config" value="smtp" />
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="SMTP" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Entry name="smtp_server" value="$server" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="4">
	<AAT:IMG name="generic_mail" tooltip="$tt" width="64" height="64" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
	<AAT:Label value="_SENDER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2" valign="top">
  <AAT:Entry name="smtp_sender" value="$sender" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_AUTHENTICATION" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
  <AAT:Selector name="smtp_authtype" list=\@auth_types selected="$auth_type" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_LOGIN" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
  <AAT:Entry name="smtp_authlogin" value="$auth_login" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_PASSWORD" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
  <AAT:Password name="smtp_authpassword" value="$auth_password" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
	<AAT:BoxCol>
<%
if (NOT_NULL($server))
{
	my ($level, $msg) = ((AAT::SMTP::Connection_Test($arg{appli})) 
		? (0, "SMTP Connection is OK !") : (2, "SMTP Connection is NOT OK !"));
	%><AAT:Message level="$level" msg="$msg" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
