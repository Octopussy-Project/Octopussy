<%
my %arg = @_;

my $url = $arg{url};
my $tablename = $arg{table};
$url .= "?table=$tablename";
my $url_sort = $url . "&table_fields_table_sort=";
my $sort = (AAT::NOT_NULL($arg{sort}) ? lc($arg{sort}) : "title");
my $role = $Session->{AAT_ROLE};
my $action_str = (($role !~ /ro/i) ? "Action" : "");
my $title = AAT::Translation("_FIELDS_OF_TABLE") . " $tablename";
%>
<AAT:Box align="C" title="$title" icon="buttons/bt_table">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_FIELD" link="${url_sort}title" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_TYPE" link="${url_sort}type"/></AAT:BoxCol>
  <AAT:BoxCol align="C"><AAT:Label value="$action_str" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $conf (Octopussy::Table::Fields_Configurations($tablename, $sort))
{
	my ($title, $type) = ($conf->{title}, $conf->{type});
%><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$title" no_trans="1" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$type" no_trans="1" /></AAT:BoxCol><%
	if ($role !~ /ro/i)
  {
%><AAT:BoxCol align="C"><AAT:Button name="remove" tooltip="_REMOVE" 
		link="$url&fieldname=$title&action=remove" /></AAT:BoxCol><%
	}
	else
	{
%><AAT:BoxCol></AAT:BoxCol><%
	}
%></AAT:BoxRow><%
}
if ($role !~ /ro/i)
{
	my @types = Octopussy::Type::Simple_List();
%><AAT:Form action="$url">
	<AAT:Form_Hidden name="table" value="$tablename" />
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="fieldname" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector name="type" list=\@types selected="WORD" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_NEW_FIELD" /></AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Form><%
}
%>
</AAT:Box>
