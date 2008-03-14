<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @dgs = Octopussy::DeviceGroup::List();
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "devicegroups_table", url => $url, sort => $sort,
  header_icon => "buttons/bt_device", header_title => "_DEVICEGROUPS",
  function => "Octopussy::DeviceGroup::Configurations",
  function_args => [ $sort ],

  fields => [
    { name => "dg_id", label => "_GROUP_NAME" },
    { name => "description", label => "_DESCRIPTION" },
		{ name => "type", label => "_TYPE" }, 
		{ name => "device", label => "_DEVICES" } ],

  actions => [
    { name => "remove", link_url => "./dialog.asp", 
			tooltip => "_REMOVE", link_type => "popup",
      link_args => [ { name => "id", value => "delete_devicegroup" },
                      { name => "arg1", field_value => "dg_id" },
                      { name => "action", value => "remove" }] } ],
  );

if ($role !~ /ro/i)
{
	my @device_fields = ( 
		{ label => "_DEVICE_NAME", value => "name" },
		{ label => "_DEVICE_ADDRESS", value => "address" },
		{ label => "_DEVICE_DESCRIPTION", value => "description" },
		{ label => "_DEVICE_TYPE", value => "type" },
    { label => "_DEVICE_MODEL", value => "model" },
		{ label => "_CITY", value => "city" },
		{ label => "_BUILDING", value => "building" },
		{ label => "_ROOM", value => "room" },
		{ label => "_RACK", value => "rack" } );
%>
<AAT:Form action="$url">
<AAT:Box align="center">
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GROUP_NAME" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>	
	<AAT:BoxCol><AAT:Label value="_DEVICES" style="B"/></AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="devicegroup" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="dg_description" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="selector_multi_device" name="devices" />
	</AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="center" cspan="3">
	<AAT:Form_Submit value="_NEW_STATIC_DEVICEGROUP" /></AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<AAT:Form action="$url">
<AAT:Box align="center">
  <AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GROUP_NAME" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:Form_Hidden name="type" value="dynamic" />
	<AAT:BoxCol><AAT:Entry name="devicegroup" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="dg_description" size="40" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_FIELD" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_VALUE" style="B"/></AAT:BoxCol>
  </AAT:BoxRow>
<%
foreach my $i (1..3)
{
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Selector name="criteria_field$i" list=\@device_fields />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="criteria_value$i" size="40" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="C" cspan="2">
  <AAT:Form_Submit value="_NEW_DYNAMIC_DEVICEGROUP" /></AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
}
%>
