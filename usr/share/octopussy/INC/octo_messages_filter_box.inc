<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% my %arg = @_; %>
<AAT:Form action="$arg{url}">
<AAT:Box>
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Label value="_SERVICE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
		<AAT:Inc file="octo_selector_service" any="1" selected="$arg{service}" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
		<AAT:Inc file="octo_selector_loglevel" any="1" selected="$arg{loglevel}" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Inc file="octo_selector_taxonomy"
		any="1" selected="$arg{taxonomy}" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
		<AAT:Inc file="octo_selector_table" any="1" selected="$arg{table}" />
	</AAT:BoxCol>
	<AAT:BoxCol scpan="2"><AAT:Form_Submit value="_FILTER" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>	
</AAT:Form>
