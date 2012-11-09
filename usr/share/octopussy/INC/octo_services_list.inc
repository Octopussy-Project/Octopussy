<%
my %arg = @_;
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};
my $lnk = "${url}?services_table_sort";
%>
<%
if ($role !~ /ro/i)
{%>
<AAT:Form action="$url">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /> (only [-_a-zA-Z0-9] chars)</AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="service" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="description" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
	<AAT:Label value="_OFFICIAL_WEBSITE" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="website" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_NEW_SERVICE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form><%
}%>
<AAT:Box align="C" title="_SERVICES" icon="buttons/bt_service">
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_NAME" link="$lnk=name" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
	<AAT:BoxCol align="R">
  <AAT:Label value="_NB_MESSAGES" link="$lnk=nb_messages" /></AAT:BoxCol>
	<AAT:BoxCol><%
if ($role !~ /ro/i)
  { %><AAT:Label value="_ACTION" style="B" /><% }
%></AAT:BoxCol>	
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $s (Octopussy::Service::Configurations($sort))
{
  my ($icon, $name, $desc, $nb) = 
		($s->{icon}, $s->{name}, $s->{description}, $s->{nb_messages});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:IMG name="$icon" width="32" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$name" link="$url?service=$name" /></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$desc" no_trans="1" /></i></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="$nb" /></AAT:BoxCol>
<AAT:BoxCol align="C"><%
if ($role !~ /ro/i)
{
%><AAT:Button name="remove" tooltip="_REMOVE" width="32" height="32"
    popup_link="./dialog.asp?id=delete_service&arg1=$name&action=remove" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
if ($role !~ /ro/i)
{%>
<AAT:Form action="$url">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /> (only [-_a-zA-Z0-9] chars)</AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="service" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="description" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
	<AAT:Label value="_OFFICIAL_WEBSITE" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="website" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_NEW_SERVICE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form><%
}%>
