<%
my %arg = @_;
my $url = $arg{url};
my $sort = (NOT_NULL($arg{sort}) ? lc($arg{sort}) : "name");
my $role = $Session->{AAT_ROLE};
%>
<AAT:Box align="C" title="_TABLES" icon="buttons/bt_table">
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_NAME" link="$lnk=name" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
if ($role !~ /ro/i)
  { %><AAT:Label value="_ACTION" style="B" /><% }
%></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
my @tcs = Octopussy::Table::Configurations($sort);
foreach my $t (@tcs)
{
  my ($name, $desc) = ($t->{name}, $t->{description});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$name" link="$url?table=$name" /></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$desc" no_trans="1" /></i></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
if ($role !~ /ro/i)
{
%><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_table&arg1=$name&action=remove" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow><%
}

if ($role !~ /ro/i)
{
%><AAT:Form action="$url">
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="table" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="description" size="30" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Form_Submit value="_NEW_TABLE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form><%
}
%>
</AAT:Box>
