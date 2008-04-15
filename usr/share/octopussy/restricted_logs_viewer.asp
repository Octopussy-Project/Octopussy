<%
my $run_dir = Octopussy::Directory("running");
my $login = $Session->{AAT_LOGIN};
my $msg_nb_lines = AAT::Translation("_MSG_NB_LINES");
my $LINES_BY_PAGE = 1000;
my $nb_lines = 0;
my $last_page = 1;
my $text = "";
my $url = "./restricted_logs_viewer.asp";

my @devices = AAT::ARRAY($Session->{device});
my @services = AAT::ARRAY($Session->{service});
my $restrictions = AAT::User::Restrictions("Octopussy", $login);
my @restricted_devices = AAT::ARRAY($restrictions->{device});
my @restricted_services = AAT::ARRAY($restrictions->{service});

my $page = $Session->{page} || 1;
my $dt = $Session->{dt};
my ($d1, $m1, $y1, $hour1, $min1) = 
	($Session->{dt1_day}, $Session->{dt1_month}, $Session->{dt1_year}, 
	$Session->{dt1_hour}, $Session->{dt1_min});
my ($d2, $m2, $y2, $hour2, $min2) = 
	($Session->{dt2_day}, $Session->{dt2_month}, $Session->{dt2_year},
	$Session->{dt2_hour}, $Session->{dt2_min});
my ($re_include, $re_include2) = 
	($Session->{re_include}, $Session->{re_include2});
my ($re_exclude, $re_exclude2) = 
	($Session->{re_exclude}, $Session->{re_exclude2});

if (AAT::NOT_NULL($Session->{cancel}))
{
	my $pid_param = $Session->{extracted};
	my $pid_file = $run_dir . "octo_extractor_${pid_param}.pid";
	$pid = `cat "$pid_file"`;
	kill USR2 => $pid;	

	($Session->{extractor}, $Session->{cancel}, $Session->{logs}, 
	$Session->{file}, $Session->{csv}, $Session->{zip}) =
    (undef, undef, undef, undef, undef, undef);	
}

if (AAT::NOT_NULL($Session->{template}))
{
	Octopussy::Search_Template::New($login, { name => $Session->{template}, 
	device => \@devices, service => \@services, 
	re_include => $Session->{re_include}, re_include2 => $Session->{re_include2},
	re_exclude => $Session->{re_exclude}, re_exclude2 => $Session->{re_exclude2} 
	} );
}

if ((AAT::NULL($Session->{extractor})) && 
		((AAT::NOT_NULL($Session->{logs})) || (AAT::NOT_NULL($Session->{file})) 
			|| (AAT::NOT_NULL($Session->{csv})) || (AAT::NOT_NULL($Session->{zip})))
	&& (($#devices >= 0) && ($#services >= 0) 
	&& ($devices[0] ne "") && ($services[0] ne "")))
{
	use Crypt::PasswdMD5;
	my $output = unix_md5_crypt(time() * rand(99));
	$output =~ s/[\/\&\$\.\?]//g;
	
	my $any = 0;
	foreach my $d (@devices)
		{ $any = 1 if ($d =~ /-ANY-/); }
	my @devices_cmd = ($any ? @restricted_devices : @devices);
	$any = 0;
	foreach my $s (@services)
    { $any = 1 if ($s =~ /-ANY-/); }	
	my @services_cmd = ($any ? @restricted_services : @services);

	my $cmd = Octopussy::Logs::Extract_Cmd_Line( { 
		devices => \@devices_cmd, services =>\@services_cmd, 
		begin => "$y1$m1$d1$hour1$min1", end => "$y2$m2$d2$hour2$min2",
		incl1 => $re_include, incl2 => $re_include2,
		excl1 => $re_exclude, excl2 => $re_exclude2, 
		pid_param => $output, output => "$run_dir/logs_${login}_$output" } );
	$Session->{export} = 
		"logs_" . join("-", @devices) . "_" . join("-", @services)
    	. "_$y1$m1$d1$hour1$min1" . "-$y2$m2$d2$hour2$min2";
	system("$cmd &");
	sleep(1);
	$Session->{page} = 1;
	$Session->{extracted} = $output;
	$Response->Redirect("$url?extractor=$output");
}

if ($Session->{extractor} eq "done")
{
	my $filename = $Session->{extracted};
	if (AAT::NOT_NULL($Session->{file}))
	{
		my $output = $Session->{export} . ".txt";
		($Session->{file}, $Session->{export}, $Session->{extractor}, 
			$Session->{extracted}) = (undef, undef, undef, undef);
		AAT::File_Save( { contenttype => "text/txt", 
			input_file => "${run_dir}/logs_${login}_$filename", 
			output_file => $output } );
	}
	elsif (AAT::NOT_NULL($Session->{csv}))
	{
		open(FILE, "< $run_dir/logs_${login}_$filename");
		while (<FILE>)
		{
   		$text .= "$1;$2;$3\n" 
				if ($_ =~ /^(\w{3} \s?\d{1,2} \d\d:\d\d:\d\d) (\S+) (.+)$/);
  	}
		close(FILE);
		my $output = $Session->{export} . ".csv";
		($Session->{csv}, $Session->{export}, $Session->{extractor},
			$Session->{extracted}) = (undef, undef, undef, undef);
		AAT::File_Save( { contenttype => "text/csv",
     	input_data => $text, output_file => $output } );
	}
	elsif (AAT::NOT_NULL($Session->{zip})) 
	{
		my $output = $Session->{export} . ".txt.gz";
		open(ZIP, "|gzip >> $run_dir/logs_${login}_$filename.gz");
		open(FILE, "< $run_dir/logs_${login}_$filename");
    while (<FILE>)
			{ print ZIP $_; }
		close(FILE);
		close(ZIP);
    ($Session->{zip}, $Session->{export}, $Session->{extractor},
			$Session->{extracted}) = (undef, undef, undef, undef);
    AAT::File_Save( { contenttype => "archive/gzip",
      input_file => "$run_dir/logs_${login}_$filename.gz", 
			output_file => $output } );
	}
	else
	{
		$text = "<table id=\"resultsTable\">";
		my $page = $Session->{page} || 1;
		open(FILE, "< $run_dir/logs_${login}_$filename");
    while (<FILE>)
    {
			if (($nb_lines >= ($page-1)*$LINES_BY_PAGE) 
					&& ($nb_lines <= ($page*$LINES_BY_PAGE)))
			{
				my $line = $Server->HTMLEncode($_);
				$line =~ s/($re_include)/<font color="red"><b>$1<\/b><\/font>/g	
					if (AAT::NOT_NULL($re_include));
				$line =~ s/($re_include2)/<font color="blue"><b>$1<\/b><\/font>/g
					if (AAT::NOT_NULL($re_include2));
				$line =~ s/(\S{120})(\S+?)/$1\n$2/g;
				$text .= "<tr class=\"boxcolor" . ($nb_lines%2+1) . "\"><td>$line</td></tr>";
			}
   		$nb_lines++;
  	}
		close(FILE);
		$last_page = int($nb_lines/$LINES_BY_PAGE) + 1;
		$text .= "</table>"; 
	}
	($Session->{cancel}, $Session->{extractor}, $Session->{logs}) = 
		(undef, undef, undef);
}

if ((AAT::NOT_NULL($Session->{extractor})) && ($Session->{extractor} ne "done"))
{
%>
<WebUI:PageTopRestricted title="Logs" onLoad="extract_progress()" />
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
<script type="text/javascript" src="INC/octo_restricted_logs_viewer_progressbar.js"> 
</script>
<%
}
else
{
%>
<WebUI:PageTopRestricted title="Logs" />
<script type="text/javascript" src="INC/octo_logs_viewer_quick_search.js">
</script>
<%
}
$Response->Include("INC/octo_logs_viewer_form.inc", url => $url, 
	devices => \@devices, services => \@services,
	restricted_devices => \@restricted_devices,
	restricted_services => \@restricted_services);
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
	page => $page, page_last => $last_page)	
	if ($last_page > 1);
%>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><%= $text %></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3">
<% 
$Response->Include("INC/octo_page_navigator.inc",
  url => "$url?extractor=done&extracted=" . $Session->{extracted}, 
	page => $page, page_last => $last_page)
	if ($last_page > 1);
%>
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
