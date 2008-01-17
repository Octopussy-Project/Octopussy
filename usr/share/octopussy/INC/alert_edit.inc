<%
my %arg = @_;

my $alert = $arg{alert};
my $conf = Octopussy::Alert::Configuration($alert);

my @devices = AAT::ARRAY($conf->{device});
my @services = AAT::ARRAY($conf->{service});
my @actions = AAT::ARRAY($conf->{action});
my @contacts = AAT::ARRAY($conf->{contact});
my $msgbody = $conf->{msgbody};

my @table = (
	[ { type => "form", 
			args => { method => "post", action => "./alert_edit.asp" } },
		{ type => "AAT_Form_Hidden", 
			args => { name => "old_alert", value => $conf->{name} } },
		{ label => "_NAME", style => "bold"}, 
		{ type => "AAT_Entry", 
			args => { name => "name", value => $conf->{name}, size => 60 } } ],
	[ { label => "_DESCRIPTION", style => "bold" },
    { type => "AAT_Entry", 
			args => { name => "description", value => $conf->{description}, 
								size => 60 } } ],
	[ { label => "_ALERT_LEVEL", style => "bold" },
    { type => "octo_selector_alert_level", 
			args => { name => "level", selected => $conf->{level} } } ],
	[ { label => "_STATUS", style => "bold" },     
		{ type => "AAT_Selector", 
			args => { name => "status", list => [ "Disabled", "Enabled" ], 
				selected => $conf->{status} } } ],
	[ { label => "<hr>", colspan => 2 } ],
	[ { label => "_DEVICES", style => "bold" },
    { type => "octo_selector_device_and_devicegroup_dynamic",
      args => { multiple => 1, size => 3, selected => \@devices } } ],
  [ { label => "_SERVICES", style => "bold" },
    { type => "octo_selector_service_dynamic",
      args => { multiple => 1, size => 3, device => \@devices,
        				selected => \@services} } ],
	[ { label => "_TAXONOMY", style => "bold" },
    { type => "octo_selector_taxonomy", 
			args => { name => "taxonomy", selected => $conf->{taxonomy} } } ],
  [ { label => "_TIMEPERIOD", style => "bold" },
    { type => "octo_selector_timeperiod", 
			args => { name => "timeperiod", selected => $conf->{timeperiod} } } ],
	[ { label => "<hr>", colspan => 2 } ],
	[ { label => "Repetition (n)", style => "bold" },
		{ type => "AAT_Selector_Number",
			args => { name => "thresold_time", min => 1, max => 100, 
								selected => $conf->{thresold_time} } } ],
	[ { label => "Duration (d)", style => "bold" },
		{ type => "AAT_Selector_Number",
			args => { name => "thresold_duration", min => 0, max => 600, 
								step => 5, selected => $conf->{thresold_duration} } } ],
	[ { label => AAT::Translation("_MSG_ALERT_RAISED_ONLY"), 
			colspan => 2, align => "center", color => "blue" } ],
	[ { label => "<hr>", colspan => 2 } ],
  [ { label => "_ACTION", style => "bold" },
    { type => "AAT_Selector",
      args => { multiple => 1, size => 2, name => "action",
                list => [ "Jabber", "Mail", "NSCA" ], 
								selected => \@actions } } ],	
	[ { label => "_CONTACTS", style => "bold" },
	 	{ type => "octo_selector_contact", 
			args => { multiple => 1, size => 3, selected => \@contacts } } ],
	[ { label => "_SUBJECT", tooltip => "_TOOLTIP_ALERT_MSG", style => "bold" },
	 	{ type => "AAT_Entry", 
			args => { name => "subject", size => 60, 
								value => $conf->{msgsubject} } } ],
	[ { label => "_BODY", tooltip => "_TOOLTIP_ALERT_MSG", style => "bold" },
		{ type => "AAT_TextArea", 
			args => { name => "body", cols => 60, rows => 5, data => $msgbody } } ],
	[ { label => "<hr>", colspan => 2 } ],
 	[ { type => "AAT_Form_Hidden", args => { name => "modify", value => "yes" } },
  	{ type => "AAT_Form_Submit", align => "center", colspan => 5, 
			args => { value => "_UPDATE" } },
   	{ type => "end_form" } ] );

$Response->Include('INC/box.inc', elements => \@table);
%>
