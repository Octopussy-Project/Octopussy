<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "cid";
my $role = $Session->{AAT_ROLE};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "contacts_table", url => $url, sort => $sort || "cid",
  header_icon => "buttons/bt_contact", header_title => "_CONTACTS",
  function => "Octopussy::Contact::Configurations",
  function_args => [ $sort ],
  fields => [
    { name => "cid", label => "ID", alignment => "left" },
    { name => "lastname", label => "_LASTNAME", alignment => "left" },
    { name => "firstname", label => "_FIRSTNAME", alignment => "left" },
    { name => "description", label => "_DESCRIPTION", alignment => "left" },
		{ name => "email", label => "_EMAIL", alignment => "left" },
		{ name => "im", label => "IM", alignment => "left" },
		{ name => "type", label => "_TYPE", alignment => "left" } ],
  actions => [
    { name => "remove", link_url => "./dialog.asp",
			tooltip => "_REMOVE", link_type => "popup",
      link_args => [ { name => "id", value => "delete_contact" },
                      { name => "arg1", field_value => "cid" },
                      { name => "action", value => "remove" } ], 
			condition => sub { my $type = shift; return ($type eq "local") },
 			condition_args => "type" } ] );

if ($role !~ /ro/i)
{
%>
<AAT:Form action="$url">
<AAT:Box align="center">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="ID" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LASTNAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_FIRSTNAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_EMAIL" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="IM" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="cid" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="lastname" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="firstname" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="description" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="email" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="im" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="7" align="C">
	<AAT:Form_Submit value="_NEW_CONTACT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<AAT:Form_Hidden name="action" value="new" />
</AAT:Form><%
}
%>
