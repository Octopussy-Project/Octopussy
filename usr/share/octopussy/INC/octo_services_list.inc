<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "services_table", url => $url, sort => $sort || "name",
  header_icon => "buttons/bt_service", header_title => "_SERVICES",
  function => "Octopussy::Service::Configurations",
  function_args => [ $sort ],
  fields => [
		{ name => "icon", type => "IMG", alignment => "center" },
    { name => "name", label => "_NAME", alignment => "left", 
			link_args => [ { name => "service", field_value=> "name" } ] },
    { name => "description", label => "_DESCRIPTION", alignment => "left" },
    { name => "nb_messages", label => "_NB_MESSAGES", alignment => "right" } ],
  actions => [
    { name => "remove", tooltip => "_REMOVE",
			link_url => "./dialog.asp", link_type => "popup",
      link_args => [ { name => "id", value => "delete_service" },
                      { name => "arg1", field_value => "name" },
                      { name => "action", value => "remove" }] } ] );

if ($role !~ /ro/i)
{%>
<AAT:Form action="$url">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="service" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="description" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_NEW_SERVICE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form><%
}%>
