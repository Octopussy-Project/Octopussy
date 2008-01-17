<%
my %arg = @_;
my $tt = $arg{tooltip};
my $db = AAT::DB::Configuration();
my ($type, $host, $user, $password, $base) =
  ($db->{type}, $db->{host}, $db->{user}, $db->{password}, $db->{db});

my $status = AAT::DB::Connection_Test();
my ($level, $msg) = ($status ? (0, "Database Connection is OK !") 
	: (2, "Database Connection is NOT OK !"));
%>
<AAT:Box width="100%">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Database" style="B" tooltip="$tt" />
	</AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_TYPE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Selector_Database name="db_type" selected="$type" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="4"><AAT:IMG name="generic_database" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="db_host" value="$host" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_USER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="db_user" value="$user" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_PASSWORD" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Password name="db_password" value="$password" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_BASE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="db_database" value="$base" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Message level="$level" msg="$msg" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
