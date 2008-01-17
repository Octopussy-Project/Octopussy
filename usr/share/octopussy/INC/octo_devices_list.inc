<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "devices_table", url => $url, sort => $sort,
  header_icon => "buttons/bt_device", header_title => "_DEVICES",
  function => "Octopussy::Device::Filtered_Configurations",
  function_args => [ $arg{dtype}, $arg{dmodel}, $sort ],

  fields => [
    { name => "name", label => "_NAME" },
    { name => "address", label => "_IP_ADDRESS" },
		{ name => "logtype", label => "_LOG_TYPE" },
    { name => "type", label => "_DEVICE_TYPE" },
    { name => "model", label => "_DEVICE_MODEL" },
    { name => "description", label => "_DESCRIPTION" },
    { name => "status", label => "_STATUS", 
			tooltip => "_TOOLTIP_DEVICE_STATUS" } ],

  actions => [
		{ name_fct => "Octopussy::Device::Parse_Action_Button1",
			name_fct_args => "name", 
			link_url => "./dialog.asp", link_type => "popup",
			link_args => [ { name => "id", field_value => "action1" },
											{ name => "arg1", field_value => "name" } ] },
		{ name_fct => "Octopussy::Device::Parse_Action_Button2",
		 	name_fct_args => "name",
			link_url => "./dialog.asp", link_type => "popup",
			link_args => [ { name => "id", field_value => "action2" },
											{ name => "arg1", field_value => "name" } ] },

		{ name => "service", link_url => "./devices.asp", tooltip => "_SERVICES",
      link_args => [ { name => "device", field_value => "name" } ] },
		{ name => "storage", link_url => "./device_storages.asp", 
			tooltip => "_STORAGES", 
			link_args => [ { name => "device", field_value => "name" } ] },
		{ name => "edit", link_url => "./device_edit.asp", tooltip => "_EDIT",
			link_args => [ { name => "device", field_value => "name" } ] },
		{ name => "report", link_url => "./device_dashboard.asp", 
			tooltip => "_DASHBOARD",
			link_args => [ { name => "device", field_value => "name" } ] },
    { name => "remove", link_url => "./dialog.asp", 
			tooltip => "_REMOVE", link_type => "popup",
      link_args => [ { name => "id", value => "delete_device" },
                      { name => "arg1", field_value => "name" },
                      { name => "action", value => "remove" }] } ],
  );

if ($role !~ /ro/i)
{
	my @log_type = ("asynchronous", "syslog");
%>
<AAT:Form action="$url">
<AAT:Box align="center">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DEVICE_NAME" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_IP_ADDRESS" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOG_TYPE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE_TYPE" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE_MODEL" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="address" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector name="logtype" list=\@log_type selected="syslog"/></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="selector_device_type_dynamic" 
		selected="$arg{dtype}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="octo_selector_device_model" 
		device_type="$arg{dtype}" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="description" /></AAT:BoxCol>
</AAT:BoxRow>	
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="6">
	<AAT:Form_Submit value="_NEW_DEVICE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
}
%>
