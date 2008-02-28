<% 
my %arg = @_; 
my $action = $arg{action}; 
%>
<AAT:Box icon="buttons/bt_config" title="_SYSTEM_CONFIG" align="C">
<AAT:BoxRow>
	<AAT:Form method="POST" action="$action">
	<AAT:BoxCol align="C">
	<AAT:Button name="save" link="$action?action=backup" />
	<AAT:Inc file="octo_selector_backup" name="file" />
  <AAT:Form_Submit name="restore" value="_RESTORE" />
  </AAT:BoxCol>
	</AAT:Form>
</AAT:BoxRow> 
<AAT:BoxRow><AAT:BoxCol><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Config_Database appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_DB" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Config_Certificate appli="Octopussy" action="$action" 
		tooltip="_TOOLTIP_SYSTEM_CERTIFICATE" /></AAT:BoxCol>
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
