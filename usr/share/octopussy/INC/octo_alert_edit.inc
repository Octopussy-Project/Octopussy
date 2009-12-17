<%
my %arg = @_;

my $conf = Octopussy::Alert::Configuration($arg{alert});
my ($a_name, $a_desc, $a_level, $a_status, $a_taxo, $a_timeperiod, 
	$a_thresold_time, $a_thresold_duration) = ($conf->{name}, 
	$conf->{description}, $conf->{level}, $conf->{status}, $conf->{taxonomy}, 
	$conf->{timeperiod}, $conf->{thresold_time}, $conf->{thresold_duration});
my ($a_re_include, $a_re_exclude) = 
	($conf->{regexp_include}, $conf->{regexp_exclude});
my ($a_msg_subject, $a_msg_body) = ($conf->{msgsubject}, $conf->{msgbody});
my ($action_host, $action_service, $action_body) = 
	($conf->{action_host}, $conf->{action_service}, $conf->{action_body});
my @devices = AAT::ARRAY($conf->{device});
my @services = AAT::ARRAY($conf->{service});
my @actions = AAT::ARRAY($conf->{action});
my @contacts = AAT::ARRAY($conf->{contact});
my $msg_alert_raised_only = AAT::Translation("_MSG_ALERT_RAISED_ONLY");
my @used_services = Octopussy::Service::List_Used();
%>
<AAT:Form action="./alert_edit.asp">
<AAT:Form_Hidden name="old_alert" value="$a_name" />
<AAT:Form_Hidden name="modify" value="yes" />
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol rspan="4"><AAT:IMG name="generic_alert" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="name" value="$a_name" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
 	<AAT:BoxCol>
  <AAT:Entry name="description" value="$a_desc" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_ALERT_LEVEL" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_alert_level" name="level" selected="$a_level" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_STATUS" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Selector_EnabledDisabled name="status" selected="$a_status" />
  </AAT:BoxCol>
</AAT:BoxRow>	
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Button name="device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICES" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_device_and_devicegroup_dynamic" 
		multiple="1" size="3" selected=\@devices /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Button name="service" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_service_dynamic" multiple="1" size="5" 
		selected=\@services restricted_services=\@used_services /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_taxonomy" name="taxonomy" 
		selected="$a_taxo" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Button name="period" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_TIMEPERIOD" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_timeperiod" 
		name="timeperiod" selected="$a_timeperiod" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Button name="msg_ok" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_REGEXP_INC" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="regexp_include" value="$a_re_include" size="40" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Button name="msg_critical" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_REGEXP_EXC" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="regexp_exclude" value="$a_re_exclude" size="40" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Repetition (n)" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector_Number name="thresold_time" min="1" max="100" 
		selected="$a_thresold_time" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Duration (d)" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector_Number name="thresold_duration" min="0" max="600"
    step="5" selected="$a_thresold_duration" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol cspan="2">
	<AAT:Label value="$msg_alert_raised_only" color="blue"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="octo_selector_action_mailing" multiple="1" size="2"
  	selected=\@actions /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R"><AAT:Button name="contact" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_CONTACTS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="octo_selector_contact" multiple="1" size="3"
		selected=\@contacts /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Label value="_SUBJECT" tooltip="_TOOLTIP_ALERT_MSG" style="B" />
	</AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="subject" value="$a_msg_subject" size="60" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_BODY" tooltip="_TOOLTIP_ALERT_MSG" style="B" />
  </AAT:BoxCol>
  <AAT:BoxCol><AAT:TextArea name="body" cols="60" rows="5" data="$a_msg_body" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_ACTION" style="B"/></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_action_program" multiple="1" size="2" 
    selected=\@actions /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_HOST" tooltip="_TOOLTIP_ALERT_MSG" style="B"/>
  </AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="action_host" size="30" value="$action_host" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_SERVICE" tooltip="_TOOLTIP_ALERT_MSG" style="B"/>
  </AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="action_service" size="30" value="$action_service" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_BODY" tooltip="_TOOLTIP_ALERT_MSG" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:TextArea name="action_body" cols="60" rows="5" data="$action_body" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3" align="C">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
