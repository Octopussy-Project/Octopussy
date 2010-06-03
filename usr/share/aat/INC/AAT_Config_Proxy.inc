<%
my %arg = @_;
my $tt = $arg{tooltip};
my $proxy = AAT::Proxy::Configuration($arg{appli});
my ($server, $port, $user, $pwd) =
  ($proxy->{server}, $proxy->{port}, $proxy->{user}, $proxy->{password});
%>
<AAT:Box width="100%">
<AAT:Form method="POST" action="$arg{action}">
<AAT:Form_Hidden name="config" value="proxy" />
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Proxy" style="B" tooltip="$arg{tooltip}" />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="proxy_server" value="$server" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="3">
	<AAT:IMG name="generic_proxy" tooltip="$tt" width="64" height="64" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_PORT" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="proxy_port" value="$port" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_USER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Entry name="proxy_user" value="$user" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
	<AAT:Label value="_PASSWORD" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
  <AAT:Password name="proxy_password" value="$pwd" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
	<AAT:BoxCol>
<%
if (NOT_NULL($server))
{
	my ($level, $msg) = ((AAT::Proxy::Connection_Test($arg{appli}))
  	? (0, "Proxy Connection is OK !") : (2, "Proxy Connection is NOT OK !"));
	%><AAT:Message level="$level" msg="$msg" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
