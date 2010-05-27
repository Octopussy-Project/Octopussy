<%
my %arg = @_;
my $nb_alerts_max = Octopussy::Parameter("max_alerts");
my $al = $arg{alert} || "";
my $dev = $arg{device} || "";
my $stat = $arg{status} || "";
$al =~ s/-ANY-//gi;
$dev =~ s/-ANY-//gi;
$stat =~ s/-ANY-//gi;
my $today = AAT::Utils::Now_String();
my $sort = (NOT_NULL($arg{sort}) ? lc($arg{sort}) : "date_time");
my $url_sort = $arg{url} . "?sort";
%>
<AAT:Form action="$arg{url}">
<AAT:Form_Hidden name="alert" value="$al" />
<AAT:Form_Hidden name="device" value="$dev" />
<AAT:Form_Hidden name="status" value="$stat" />
<AAT:Box>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="4">
	<AAT:Label value="_COMMENT" style="B"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Label value="_STATUS" style="B"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_SELECTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="4" rspan="2">
	<AAT:TextArea name="comment" cols="100" rows="3" wrap="on" data="$today" />
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_alert_status" name="edit_status" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Form_Submit name="selectall" value="_SELECT_ALL" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C">
	<AAT:Label value="_ALERT_NAME" link="$url_sort=alert_id" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_DEVICE" link="$url_sort=device" /></AAT:BoxCol>	
	<AAT:BoxCol align="C">
  <AAT:Label value="_DATETIME" link="$url_sort=date_time" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_LOG" link="$url_sort=log" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_STATUS" link="$url_sort=status" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="_SELECTION" /></AAT:BoxCol>
</AAT:BoxRow>	
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN});
my @res_alerts = ARRAY($restricts->{alert});
my $limit = ((scalar(@res_alerts) > 0) ? undef : $nb_alerts_max);
my @alerts = Octopussy::Alert::Tracker($al, $dev, $stat, $sort, $limit);
my $nb = 0;
foreach my $a (@alerts)
{
	my $match = 0;
	if (scalar(@res_alerts) > 0)
	{
		foreach my $res (@res_alerts)
  		{	$match = 1	if ($res eq $a->{alert_id}); }
	}
	else
		{ $match = 1; }
	if ($match)
	{
		my ($alert_id, $device, $dt, $log, $comment, $status, $log_id) 
			= ($a->{alert_id}, $a->{device}, $a->{date_time}, 
					$Server->HTMLEncode($a->{log}), $Server->HTMLEncode($a->{comment}), 
					$a->{status}, $a->{log_id});
		$log =~ s/\n/<br>/g;
		my $color = ($a->{level} =~ /Critical/i ? "red" : "orange"); %>
	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Label value="$alert_id" color="$color"/></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$device" color="$color"/></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$dt" color="$color"/></AAT:BoxCol>
		<AAT:BoxCol><%= "$log<br><i><b>$comment</b></i>" %></AAT:BoxCol>
		<AAT:BoxCol align="C"><AAT:Label value="$status" /></AAT:BoxCol>
		<AAT:BoxCol align="C">
		<AAT:CheckBox name="alert_id_$log_id" selected="$arg{selectall}" />
		</AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
  <%
		$nb++;
	}
	last	if ($nb >= $nb_alerts_max);
}
%>
</AAT:Box>
</AAT:Form>
