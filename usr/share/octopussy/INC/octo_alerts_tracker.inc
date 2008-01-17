<%
my %arg = @_;
my $nb_alerts_max = Octopussy::Parameter("max_alerts");
my $al = $arg{alert} || "";
my $dev = $arg{device} || "";
my $stat = $arg{status} || "";
$al =~ s/-ANY-//gi;
$dev =~ s/-ANY-//gi;
$stat =~ s/-ANY-//gi;

my $today = AAT::Datetime::Now_String();

my $sort = ((defined $arg{sort} && $arg{sort} ne "") 
	? lc($arg{sort}) : "date_time");
my $url_sort = $arg{url} . "?sort=";

my @table = (
	[ { type => "form", args => { method => "post", action => $arg{url} } },
		{ type => "AAT_Form_Hidden",
      args => { name => "alert" , value => $al } },
    { type => "AAT_Form_Hidden",
      args => { name => "device" , value => $dev } },
    { type => "AAT_Form_Hidden",
      args => { name => "status" , value => $stat } } ],
	[ { label => "_COMMENT", colspan => 4, align => "center", style => "B" }, 
		{ label => "_STATUS", align => "center", style => "B" },
    { label => "_SELECTION", align => "center", style => "B" } ],
	[ { type => "AAT_TextArea", align => "center", colspan => 4, rowspan => 2,
      args => { name => "comment", cols => 100, rows => 3,
                wrap => "on", data => $today } },
    { type => "octo_selector_alert_status", 
			args => { name => "edit_status" } },
		{ type => "AAT_Form_Submit", align => "center",
      args => { name => "selectall", value => "Select All" } } ],
  [ { type => "AAT_Form_Submit", colspan => 2, align => "center",
      args => { value => "_UPDATE" } } ],
	[ { label => "<hr>", colspan => 6 } ],
	[	{ label => "_ALERT_NAME", align => "center", 
			link => $url_sort . "alert_id" },
   	{ label => "_DEVICE", align => "center", link => $url_sort . "device" },
		{ label => "_DATETIME", align => "center", link => $url_sort . "date_time" },
   	{ label => "_LOG", align => "center", link => $url_sort . "log" },
		{ label => "_STATUS", align => "center", link => $url_sort . "status" }, 
		{ label => "_SELECTION", align => "center" } ],
	[ { label => "<hr>", colspan => 6 } ] );

my $restricts = AAT::User::Restrictions($Session->{AAT_LOGIN});
my @res_alerts = AAT::ARRAY($restricts->{alert});
my $limit = (($#res_alerts >= 0) ? undef : $nb_alerts_max);
my @alerts = Octopussy::Alert::Tracker($al, $dev, $stat, "", $limit);
my $nb = 0;
foreach my $a (@alerts)
{
	my $match = 0;
	if ($#res_alerts >= 0)
	{
		foreach my $res (@res_alerts)
  		{	$match = 1	if ($res eq $a->{alert_id}); }
	}
	else
	{
		$match = 1;
	}
	if ($match)
	{
		my $color = ($a->{level} =~ /Critical/i ? "red" : "orange");
  	push(@table, [ { label => $a->{alert_id}, color => $color },
  	{ label => $a->{device}, color => $color },
		{ label => $a->{date_time}, color => $color },
  	{ label => $Server->HTMLEncode($a->{log})
    	. "<br><i><b>" . $Server->HTMLEncode($a->{comment}). "</b></i>" },
   	{ label => $a->{status}, align => "center" },
   	{ type => "AAT_CheckBox", align => "center",
    	args => { name => "alert_id_$a->{log_id}",           
			selected => $arg{selectall} } } ] );
		$nb++;
	}
	last	if ($nb>=$nb_alerts_max);
}
push(@table, [ { type => "end_form" } ]);

$Response->Include('INC/box.inc', width => "100%", elements => \@table);
%>
