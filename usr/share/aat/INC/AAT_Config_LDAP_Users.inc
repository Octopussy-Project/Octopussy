<%
my %arg = @_;
my $tt = $arg{tooltip};
my $ldap = AAT::LDAP::Configuration();
my ($server, $base, $filter) =
  ($ldap->{users_server}, $ldap->{users_base}, $ldap->{users_filter});
%>
<AAT:Box width="100%">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="LDAP" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="ldap_users_server" value="$server" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol rspan="3"><AAT:IMG name="generic_users" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_BASE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="ldap_users_base" value="$base" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_USERS_FILTER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="ldap_users_filter" value="$filter" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<%
if (AAT::NOT_NULL($server))
{
  my ($level, $msg) = ((AAT::LDAP::Users_Connection_Test())
		? (0, "LDAP Connection is OK !") : (2, "LDAP Connection is NOT OK !"));
%>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"><AAT:Message level="$level" msg="$msg" /></AAT:BoxCol>
</AAT:BoxRow>
<%
}
%>
</AAT:Box>
