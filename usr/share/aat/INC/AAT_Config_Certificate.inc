<%
my %arg = @_;
my $tt = $arg{tooltip};
#my $certif = AAT::Certificate::Configuration();
%>
<AAT:Box width="100%">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_CERTIFICATE" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_COUNTRY" style="B" tooltip="$tt" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="certif_country" value="$country" size="2" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol rspan="6"><AAT:IMG name="generic_keys" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
	<AAT:Label value="_STATE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_state" value="$state" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_CITY" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_city" value="$city" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_ORGANIZATION" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_org" value="$org" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_ORGANIZATIONAL_UNIT" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_org_unit" value="$org_unit" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_COMMON_NAME" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_common_name" value="$common_name" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol valign="top">
  <AAT:Label value="_EMAIL" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol valign="top">
  <AAT:Entry name="certif_email" value="$email" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
