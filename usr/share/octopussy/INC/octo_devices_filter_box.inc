<%
my %arg = @_;
my @log_type = ("-ANY-", "asynchronous", "syslog");
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Label value="_LOG_TYPE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Selector name="logtype" list=\@log_type selected="$arg{logtype}" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Label value="_DEVICE_TYPE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_device_type_dynamic" 
		selected="$arg{dtype}" any="1" /></AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Label value="_DEVICE_MODEL" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_device_model_with_any" name="device_model_filter"
		device_type="$arg{dtype}" selected="$arg{dmodel}" />
	</AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_FILTER" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
