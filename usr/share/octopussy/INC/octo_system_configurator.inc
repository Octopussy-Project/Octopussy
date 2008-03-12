<% 
my %arg = @_; 
my $action = $arg{action}; 
%>
<AAT:Box icon="buttons/bt_config" title="_SYSTEM_CONFIG" align="C">
<AAT:BoxRow>
	<AAT:BoxCol align="C">
	<AAT:Box align="C">
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_BACKUP" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="_RESTORE" style="B" /></AAT:BoxCol>
		<AAT:BoxCol align="C"><AAT:Label value="_RESTORE_FROM_FILE" style="B" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol align="C">
    <AAT:Button name="backup" link="$action?action=backup" /></AAT:BoxCol>
		<AAT:Form action="$action">
    <AAT:BoxCol align="C">
    <AAT:Form_Submit name="action" value="restore" btname="restore" />
		</AAT:BoxCol>
		<AAT:BoxCol>
		<AAT:Inc file="octo_selector_backup" name="file" /></AAT:BoxCol>
		</AAT:Form>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:BoxCol>
</AAT:BoxRow> 
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_Database appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_DB" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
	<!-- AAT:ConfigCertificate -->
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_Proxy appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_PROXY" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_LDAP_Contacts appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_LDAP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_LDAP_Users appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_LDAP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_SMTP appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_SMTP" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_XMPP appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_JABBER" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_NSCA appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_NSCA" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
