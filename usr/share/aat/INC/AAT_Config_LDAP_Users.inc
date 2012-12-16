<%
my %arg = @_;
my $tt = $arg{tooltip};
my $ldap = AAT::LDAP::Configuration($arg{appli});
my ($server, $auth_dn, $auth_password, $base, $filter, $attribute_login) =
  ($ldap->{users_server}, $ldap->{users_auth_dn},
  $ldap->{users_auth_password}, $ldap->{users_base}, 
  $ldap->{users_filter}, $ldap->{users_attribute_login});
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
	<AAT:BoxCol rspan="5">
	<AAT:IMG name="generic_users" tooltip="$tt" width="64" height="64" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_AUTH_DN" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="ldap_users_auth_dn" value="$auth_dn" size="50" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_AUTH_PASSWORD" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Password name="ldap_users_auth_password" value="$auth_password" size="50" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
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
	<AAT:BoxCol><AAT:Label value="_LOGIN" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="ldap_users_attribute_login" value="$attribute_login" size="30" />
    </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
	<AAT:BoxCol>
<%
if (NOT_NULL($server))
{
  my ($level, $msg) = ((AAT::LDAP::Users_Connection_Test($arg{appli}))
		? (0, "LDAP Connection is OK !") : (2, "LDAP Connection is NOT OK !"));
	%><AAT:Message level="$level" msg="$msg" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
