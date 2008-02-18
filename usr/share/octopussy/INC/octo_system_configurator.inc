<% my %arg = @_; %>
<AAT:Form method="POST" action="$arg{action}">
<AAT:Box icon="buttons/bt_config" title="_SYSTEM_CONFIG" align="center">
<!--
	<AAT:BoxRow valign="middle">
	<AAT:BoxCol>
		<AAT:Button name="save" tooltip="_BACKUP" 
			link="$arg{action}?action=backup" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
		<AAT:Inc file="octo_selector_backup" name="file" />
    <AAT:Form_Submit name="restore" value="_RESTORE" />
  </AAT:BoxCol>
	</AAT:BoxRow> 
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
-->
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_Database tooltip="_TOOLTIP_SYSTEM_DB" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2">
  <AAT:Config_Certificate tooltip="_TOOLTIP_SYSTEM_CERTIFICATE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_Proxy tooltip="_TOOLTIP_SYSTEM_PROXY" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
  <AAT:Config_LDAP_Contacts tooltip="_TOOLTIP_SYSTEM_LDAP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_LDAP_Users tooltip="_TOOLTIP_SYSTEM_LDAP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_SMTP tooltip="_TOOLTIP_SYSTEM_SMTP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_XMPP tooltip="_TOOLTIP_SYSTEM_JABBER" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Config_NSCA tooltip="_TOOLTIP_SYSTEM_NSCA" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
    <AAT:BoxCol cspan="2" align="center">
    <AAT:Form_Hidden name="submit" value="submit" />
    <AAT:Form_Submit value="_MSG_UPDATE_CONFIG" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
