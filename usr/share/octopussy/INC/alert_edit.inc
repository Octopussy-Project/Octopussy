<%
my %arg = @_;

my $alert = $arg{alert};
my $conf = Octopussy::Alert::Configuration($alert);
my ($a_name, $a_desc, $a_level, $a_status, $a_taxo) = 
	($conf->{name}, $conf->{description}, $conf->{level}, 
		$conf->{status}, $conf->{taxonomy});
my @devices = AAT::ARRAY($conf->{device});
my @services = AAT::ARRAY($conf->{service});
my @actions = AAT::ARRAY($conf->{action});
my @contacts = AAT::ARRAY($conf->{contact});
my ($a_msg_subject, $a_msg_body) = ($conf->{msgsubject}, $conf->{msgbody});
my $msg_alert_raised_only = AAT::Translation("_MSG_ALERT_RAISED_ONLY");
%>
<AAT:Form action="./alert_edit.asp">
<AAT:Form_Hidden name="old_alert" value="$a_name" />
<AAT:Form_Hidden name="modify" value="yes" />
<[ { type => "form",
      args => { method => "post", action => "./alert_edit.asp" } },
    { type => "AAT_Form_Hidden",
      args => { name => "old_alert", value => $conf->{name} } },
    { label => "_NAME", style => "bold"},
    { type => "AAT_Entry",
      args => { name => "name", value => $conf->{name}, size => 60 } } ],
  [ { type => "AAT_Form_Hidden", args => { name => "modify", value => "yes" } },
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
  <AAT:Inc file="octo_selector_alert_level" name="level" value="$a_level" />
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
  <AAT:Inc file="octo_selector_service_dynamic"
    multiple="1" size="3" device=\@devices selected=\@services /></AAT:BoxCol>
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
		name="timeperiod" selected="$a_period" /></AAT:BoxCol>
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
	<AAT:BoxCol><AAT:Selector name="action" multiple="1" size="2"
                list => [ "Jabber", "Mail", "NSCA" ],
                selected => \@actions</AAT:BoxCol>
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
  <AAT:BoxCol><AAT:TextArea name="body" cols="60" rows="5" data="$a_msg_body" size="60" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3" align="C">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<%
my @table = (
	[ { type => "form", 
			args => { method => "post", action => "./alert_edit.asp" } },
		{ type => "AAT_Form_Hidden", 
			args => { name => "old_alert", value => $conf->{name} } },
		{ label => "_NAME", style => "bold"}, 
		{ type => "AAT_Entry", 
			args => { name => "name", value => $conf->{name}, size => 60 } } ],
 	[ { type => "AAT_Form_Hidden", args => { name => "modify", value => "yes" } },
  	{ type => "AAT_Form_Submit", align => "center", colspan => 5, 
			args => { value => "_UPDATE" } },
   	{ type => "end_form" } ] );

$Response->Include('INC/box.inc', elements => \@table);
%>
