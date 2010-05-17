<%
my $device = $Request->QueryString("device");
my $sort = $Request->QueryString("wizard_table_sort");
my $action = $Request->QueryString("action");
my $msg = $Request->QueryString("log");
my $timestamp = $Request->QueryString("timestamp");

my $title = (NULL($device) 
  ? AAT::Translation("_LOGS_WIZARD") 
  : sprintf("%s (%s)", AAT::Translation("_LOGS_WIZARD"), $device));
%>
<WebUI:PageTop title="$title" />
<%
if ($Session->{AAT_ROLE} !~ /ro/)
{
	if (NULL($device))
	{
		%><AAT:Inc file="octo_wizard" url="./wizard.asp" sort="$sort" /><%
	}
	else
	{
		my @messages = Octopussy::Message::Wizard($device);
		if ($action eq "remove")
		{
			Octopussy::Logs::Remove($device, $messages[$msg-1]->{re});
      AAT::Syslog("octo_WebUI", "WIZARD_REMOVE_PATTERN", $device, 
        $messages[$msg-1]->{re});
			$Response->Redirect("./wizard.asp?device=$device");
		}
		elsif ($action eq "remove_minute")
		{
			my ($year, $month, $day, $hour, $min) = ($1, $2, $3, $4, $5)
  			if ($timestamp =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/);
			Octopussy::Logs::Remove_Minute($device, $year, $month, $day, $hour, $min);
      AAT::Syslog("octo_WebUI", "WIZARD_REMOVE_MINUTE", $device, 
        "$year/$month/$day $hour:$min");
			$Response->Redirect("./wizard.asp?device=$device");
		}
		my $i = 1;
		my $new_timestamp = "";
		my $nb_max = Octopussy::Parameter("wizard_max_msgs");
		if (scalar(@messages) >= $nb_max)
		{
			my $str = sprintf(AAT::Translation("_MSG_WIZARD_MSGS_LIST_LIMITED_TO"), 
				$nb_max);
		%><AAT:Message msg="$str" level="1" /><%
		}
		foreach my $m (@messages)
		{
				if ($new_timestamp ne $m->{timestamp})
				{
					$new_timestamp = $m->{timestamp};
					%><AAT:Inc file="octo_box_remove_minute_log" 
							device="$device" timestamp="$new_timestamp" /><%
				}
			 	$Response->Include('INC/octo_wizard_new_msg.inc', 
					device => $device, name => "#" . $i++, modified => $m->{modified}, 
					orig => $m->{orig}, re => $m->{re}, nb => $m->{nb});
		}
	}
}
%>
<WebUI:PageBottom />
