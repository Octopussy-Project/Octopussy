<%
my %arg = @_;

my $form = $arg{form};
my $url = $arg{url};
my $device = $arg{device};
my $service = $arg{service};
my @report_list = Octopussy::Statistic_Report::List();

if ($#report_list >= 0)
{
	my @table = (
  [ { type => "form", 
			args => { method => "post", action => "./scheduler.asp" } } ],
	[ { label => "_NAME", align => "right", style => "bold" },
    { type => "AAT_Entry", args => { name => "name" } },
    { label => "_REPORT",  align => "right", style => "bold" },
    { type => "selector", args => { name => "report", list => \@report_list } },
    { label => "", colspan => 2 } ],
  [ { label => "<hr>", colspan => 6 } ],	
	[ { label => "_DEVICE", align => "right", style => "bold" },
    { type => "octo_selector_device_and_devicegroup_dynamic",
      args => { url => "$url?device=", selected => $device } },
    { label => "_SERVICE", align => "right", style => "bold" },
    { type => "octo_selector_service_dynamic",
      args => { url => "$url?device=$device&service=",
      device => $device, selected => $service } },
    { label => "_TAXONOMY", align => "right", style => "bold" },
    { type => "octo_selector_taxonomy", args => { any => 1 } } ],
  [ { label => "<hr>", colspan => 6 } ],
  [ { label => "_START", align => "right", style => "bold" },
    { type => "AAT_Selector_Time",
      args => { name => "start", step => 5, selected => "00/5" } } ],
  [ { label => "<hr>", colspan => 6 } ],
	[ { label => "Mail Export", colspan => 6, style => "bold" } ], 
	[ { label => "Recipients" },
    { type => "octo_selector_contact",
      args => { multiple => 1, size => 3, name => "mail_recipients" } },
    { label => "Subject" },
    { type => "AAT_Entry", colspan => 3, args => { name => "mail_subject" } } ],
  [ { label => "FTP Export", colspan => 6, style => "bold" } ], 
	[ { label => "Host" },
    { type => "AAT_Entry", args => { name => "ftp_host" } },
    { label => "Directory" },
    { type => "AAT_Entry", colspan => 3, args => { name => "ftp_dir" } } ],
  [ { label => "User" },
    { type => "AAT_Entry", args => { name => "ftp_user" } },
    { label => "Password" },
    { type => "AAT_Password", colspan => 3, args => { name => "ftp_pwd" } } ],
  [ { label => "SCP Export", style => "bold", colspan => 6 } ],
  [ { label => "Host" },
    { type => "AAT_Entry", args => { name => "scp_host" } },
    { label => "Directory" },
    { type => "AAT_Entry", colspan => 3, args => { name => "scp_dir" } } ],
  [ { label => "User" },
    { type => "AAT_Entry", args => { name => "scp_user" } },
    { label => "_SSH_PUBKEY_REQUIRED", colspan => 4, color => "red" } ],
  [ { label => "<hr>", colspan => 6 } ],
  [ { type => "AAT_Form_Submit", value="_SCHEDULE", 
			align => "center", colspan => 6 },
    { type => "end_form" } ]
  );
	$Response->Include('INC/box.inc', elements => \@table);
}
else
{
	%><div align="center">
	<AAT:Label value="_MSG_NEED_REPORT_FOR_SCHEDULE" link="./reports.asp" />
	</div><%
}
%>
