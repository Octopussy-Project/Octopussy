<%
my %arg = @_;
my @used_services = Octopussy::Service::List_Used();

my @table = (
  [ { type => "form", args => { method => "post", action => $arg{url} } },
    { label => "_STATIC_ALERT_CONFIGURATION",
      align => "center", style => "bold", colspan => 2 } ],
  [ { label => "<hr>", colspan => 2 } ],
  [ { label => "_ALERT_NAME" },
    { type => "AAT_Entry", args => { name => "alert", length => 40 } } ],
  [ { label => "_ALERT_DESCRIPTION" },
    { type => "AAT_Entry", args => { name => "description", length => 40 } } ],
  [ { label => "_ALERT_LEVEL" },
    { type => "octo_selector_alert_level", args => { name => "level" } } ],
  [ { label => "<hr>", colspan => 2 } ],
#  [ { label => "Devices" },
#    { type => "octo_selector_device_and_devicegroup_dynamic",
#      args => { multiple => 1, size => 3, selected => \@devices } } ],
#  [ { label => "Services" },
#    { type => "octo_selector_service_dynamic",
#      args => { multiple => 1, size => 3, selected => \@services,
#				restricted_services => \@used_services } } ],
#  [ { label => "Taxonomy" },
#    { type => "octo_selector_taxonomy", args => { name => "taxonomy" } } ],
#  [ { label => "TimePeriod" },
#    { type => "octo_selector_timeperiod", args => { name => "timeperiod" } } ],
  [ { label => "<hr>", colspan => 2 } ],
  [ { label => "_ACTION" },
    { type => "AAT_Selector",
      args => { multiple => 1, size => 2, name => "action",
                list => [ "Jabber", "Mail" ] } } ],
  [ { label => "_CONTACTS" },
    { type => "octo_selector_contact", args => { multiple => 1, size => 3 } } ],
  [ { label => "_SUBJECT" },
    { type => "AAT_Entry", args => { name => "subject", length => 40 } } ],
  [ { label => "_BODY" },
    { type => "AAT_TextArea", 
			args => { name => "body", cols => 60, rows => 5 } } ],
  [ { label => "<hr>", colspan => 2 } ],
  [ { type => "AAT_Form_Submit", colspan => 2, align => "center",
      args => { value => "_NEW_STATIC_ALERT" } },
    { type => "end_form" } ]
  );

$Response->Include('INC/box.inc', elements => \@table);
%>
