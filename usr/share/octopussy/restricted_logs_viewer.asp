<%
my $f = $Request->Form();
my $run_dir = Octopussy::FS::Directory("running");
my $login = $Session->{AAT_LOGIN};
my $msg_nb_lines = AAT::Translation("_MSG_NB_LINES");
my $LINES_BY_PAGE = 1000;
my $nb_lines = 0;
my $last_page = 1;
my $user_limit_reached = 0;
my $text = "";
my $url = "./restricted_logs_viewer.asp";

my @devices = ARRAY($Session->{device});
my @services = ARRAY($Session->{service});

my $page = $Session->{page} || 1;
my $dt = $Session->{dt};
my ($date1, $hour1, $min1) = 
	($Session->{dt1_date}, $Session->{dt1_hour}, $Session->{dt1_min}); 
my ($date2, $hour2, $min2) = 
	($Session->{dt2_date}, $Session->{dt2_hour}, $Session->{dt2_min}); 
my ($re_include, $re_include2, $re_include3) = 
	($Session->{re_include}, $Session->{re_include2}, $Session->{re_include3});
my ($re_exclude, $re_exclude2, $re_exclude3) = 
	($Session->{re_exclude}, $Session->{re_exclude2}, $Session->{re_exclude3});
$date1 =~ s/-//g;
$date2 =~ s/-//g;

$Response->Redirect("./login.asp?redirect=/restricted_logs_viewer.asp")
    if (NULL($Session->{AAT_LOGIN}));

if (NOT_NULL($Session->{cancel}))
{
	my $pid_param = $Session->{extracted};
	my $pid_file = $run_dir . "octo_extractor_${pid_param}.pid";
  	my $pid = Octopussy::PID_Value($pid_file);
	kill USR2 => $pid;	
	($Session->{extractor}, $Session->{cancel}, $Session->{logs}, 
	$Session->{file}, $Session->{csv}, $Session->{zip}) =
    (undef, undef, undef, undef, undef, undef);	
}

if (NOT_NULL($f->{template}))
{
	if (NOT_NULL($f->{template_save}))
  	{
		Octopussy::Search_Template::New($login, { name => $f->{template}, 
			device => \@devices, service => \@services, 
      		loglevel => $Session->{loglevel}, taxonomy => $Session->{taxonomy},
      		msgid => $Session->{msgid},
      		begin => "$date1$hour1$min1", end => "$date2$hour2$min2", 
			re_include => $re_include, re_include2 => $re_include2,
			re_include3 => $re_include3, re_exclude => $re_exclude, 
			re_exclude2 => $re_exclude2, re_exclude3 => $re_exclude3 } );
	}
	elsif (NOT_NULL($f->{template_remove}))
		{ Octopussy::Search_Template::Remove($login, $f->{template}); }
}

if ((NULL($Session->{extractor})) && 
		((NOT_NULL($f->{logs})) || (NOT_NULL($f->{file})) 
			|| (NOT_NULL($f->{csv})) || (NOT_NULL($f->{zip})))
	&& ((scalar(@devices) > 0) && (scalar(@services) > 0) 
	&& ($devices[0] ne "") && ($services[0] ne "")))
{
	use Crypt::PasswdMD5;
	my $output = unix_md5_crypt(time() * rand(99));
	$output =~ s/[\/\&\$\.\?]//g;
	
	my $any = 0;
	foreach my $d (@devices)
		{ $any = 1 if ($d =~ /-ANY-/); }
	my @devices_cmd = ($any ? @{$Session->{restricted_devices}} : @devices);
	$any = 0;
	foreach my $s (@services)
    	{ $any = 1 if ($s =~ /-ANY-/); }	
	my @services_cmd = ($any ? @{$Session->{restricted_services}} : @services);
	if (AAT::Datetime::Delta("$date1 $hour1:$min1:00", "$date2 $hour2:$min2:00")
				> $Session->{restricted_minutes_search})
	{
		$user_limit_reached = 1;
	}
	else
	{
		my $cmd = Octopussy::Logs::Extract_Cmd_Line( { 
			devices => \@devices_cmd, services =>\@services_cmd, 
			loglevel => $Session->{loglevel}, taxonomy => $Session->{taxonomy},
			msgid => $Session->{msgid},
			begin => "$date1$hour1$min1", end => "$date2$hour2$min2",
			includes => [$re_include, $re_include2, $re_include3],
    		excludes => [$re_exclude, $re_exclude2, $re_exclude3],
			pid_param => $output, user => $Session->{AAT_LOGIN},
			output => "$run_dir/logs_${login}_$output" } );
		$Session->{export} = 
			"logs_" . join("-", @devices) . "_" . join("-", @services)
    		. "_$date1$hour1$min1" . "-$date2$hour2$min2";
		Octopussy::Commander("$cmd &");

		$Session->{progress_current} = 0;
  		$Session->{progress_total} = 0;
  		$Session->{progress_match} = 0;
		$Session->{page} = 1;
		$Session->{progress_running} = $Session->{extracted} = $output;
		
		my $cache = Octopussy::Cache::Init('octo_extractor');
    	$cache->set("status_$output", "Starting... [0/1] [0]");
    
		$Response->Redirect("$url?extractor=$output");
	}
}

if ($Session->{extractor} eq "done")
{
	if (NOT_NULL($Session->{file}) || NOT_NULL($Session->{csv})
		|| NOT_NULL($Session->{zip}))
	{
		$Response->Redirect("./export_extract.asp");
	}
	else
	{
		my $filename = $Session->{extracted};
		$text = "<table id=\"resultsTable\">";
		my $page = $Session->{page} || 1;
		my $hre_inc = $Server->HTMLEncode($re_include);
    my $hre_inc2 = $Server->HTMLEncode($re_include2);
    my $hre_inc3 = $Server->HTMLEncode($re_include3);
    if (defined open(my $FILE, '<', "$run_dir/logs_${login}_$filename"))
	{
    	while (<$FILE>)
    	{
			if (($nb_lines >= ($page-1)*$LINES_BY_PAGE) 
					&& ($nb_lines <= ($page*$LINES_BY_PAGE)))
			{
				my $line = $Server->HTMLEncode($_);
				$line =~ s/($hre_inc)/<font color="red"><b>$1<\/b><\/font>/g
          if (NOT_NULL($hre_inc));
        $line =~ s/($hre_inc2)/<font color="green"><b>$1<\/b><\/font>/g
          if (NOT_NULL($hre_inc2));
        $line =~ s/($hre_inc3)/<font color="blue"><b>$1<\/b><\/font>/g
          if (NOT_NULL($hre_inc3));
				$line =~ s/(\S{120})(\S+?)/$1\n$2/g;
				$text .= "<tr class=\"boxcolor" . ($nb_lines%2+1) . "\"><td>$line</td></tr>";
			}
   		$nb_lines++;
  		}
		close($FILE);
	}
		$last_page = int($nb_lines/$LINES_BY_PAGE) + 1;
		$text .= "</table>"; 
	}
	($Session->{cancel}, $Session->{extractor}, $Session->{logs}) = 
		(undef, undef, undef);
}

if ((NOT_NULL($Session->{extractor})) && ($Session->{extractor} ne "done"))
{
%><WebUI:PageTopRestricted title="_LOGS_VIEWER" onLoad="extract_progress()" />
	<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
	<script type="text/javascript" src="INC/octo_restricted_logs_viewer_progressbar.js"> 
	</script><%
}
else
{
%><WebUI:PageTopRestricted title="_LOGS_VIEWER" />
	<script type="text/javascript" src="INC/octo_logs_viewer_quick_search.js">
	</script><%
}
$Response->Include("INC/octo_logs_viewer_form.inc", url => $url, 
	devices => \@devices, services => \@services);
if ($user_limit_reached)
{
  my $msg = sprintf(AAT::Translation("_MSG_USER_CAN_ONLY_VIEW_N_MINUTES_LOGS"), 
		$Session->{restricted_minutes_search});
%><AAT:Message level="2" msg="$msg" /><%
}
else
{
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3">
	<AAT:Label value="_QUICK_SEARCH_ON_THIS_PAGE" style="B" />
	<input id="filter" size="30" style="color:orange" onkeydown="Timer();" />
	<AAT:Label value="$msg_nb_lines" style="B"/>
	<span id="nb_lines"><b><%= $nb_lines %></b></span>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><div id="progressbar_cancel"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_bar"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_progress"></div></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="3">
<% 
$Response->Include("INC/octo_page_navigator.inc", 
	url => "$url?extractor=done&extracted=" . $Session->{extracted}, 
	page => $page, page_last => $last_page)	if ($last_page > 1);
%>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><%= $text %></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3">
<% 
$Response->Include("INC/octo_page_navigator.inc",
  url => "$url?extractor=done&extracted=" . $Session->{extracted}, 
	page => $page, page_last => $last_page)	if ($last_page > 1);
%>
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<%
}
%>
<WebUI:PageBottom />
