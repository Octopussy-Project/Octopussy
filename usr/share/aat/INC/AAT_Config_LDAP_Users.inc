<%
my %arg = @_;
my $tt = $arg{tooltip};
my $ldap = AAT::LDAP::Configuration($arg{appli});
my ($server, $base, $filter) =
  ($ldap->{users_server}, $ldap->{users_base}, $ldap->{users_filter});
%>
<AAT:Box width="100%">
<AAT:Form method="POST" action="$arg{action}">
<AAT:Form_Hidden name="config" value="ldap_users" />
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="LDAP" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="ldap_users_server" value="$server" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol rspan="3" valign="top">
	<AAT:IMG name="generic_users" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_BASE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="ldap_users_base" value="$base" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_FILTER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="ldap_users_filter" value="$filter" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
	<AAT:BoxCol>
<%
if (AAT::NOT_NULL($server))
{
  my ($level, $msg) = ((AAT::LDAP::Users_Connection_Test($arg{appli}))
		? (0, "LDAP Connection is OK !") : (2, "LDAP Connection is NOT OK !"));
	%><AAT:Message level="$level" msg="$msg" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
