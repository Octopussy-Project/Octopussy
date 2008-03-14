<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $tt = $arg{tooltip};
my %c = AAT::Certificate::Authority_Configuration("Octopussy");
%>
<AAT:Box width="100%">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_CERTIFICATE" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_COUNTRY" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_Country_Code name="certif_country" selected="$c{country}" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="6">
	<AAT:IMG name="generic_keys" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
	<AAT:Label value="_STATE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_state" value="$c{state}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_CITY" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_city" value="$c{city}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_ORGANIZATION" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_org" value="$c{org}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_ORGANIZATIONAL_UNIT" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_org_unit" value="$c{org_unit}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_COMMON_NAME" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_common_name" value="$c{common_name}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_EMAIL" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_email" value="$c{email}" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
