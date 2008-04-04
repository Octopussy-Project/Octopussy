<%
print "Session Logfile: $Session->{logfile}";
my $run_dir = Octopussy::Directory("running");
my $login = $Session->{AAT_LOGIN};
my $msg_nb_lines = AAT::Translation("_MSG_NB_LINES");
my $LINES_BY_PAGE = 1000;
my $export_filename = undef;
my $nb_lines = 0;
my $last_page = 1;
my $text = "";

my @devices = AAT::ARRAY($Session->{device});
my @services = AAT::ARRAY($Session->{service});

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
	my $pid_file = $run_dir . "octo_extractor.pid";
	$pid = `cat "$pid_file"`;
	kill HUP => $pid;	

	($Session->{extractor}, $Session->{logfile}, $Session->{cancel},
  $Session->{logs}, $Session->{file}, $Session->{csv}, $Session->{zip}) =
    (undef, undef, undef, undef, undef, undef, undef);	
}

if (AAT::NOT_NULL($Session->{template}))
{
	Octopussy::Search_Template::New( { name => $Session->{template}, 
	device => \@devices, service => \@services, 
	re_include => $Session->{re_include}, re_include2 => $Session->{re_include2},
	re_exclude => $Session->{re_exclude}, re_exclude2 => $Session->{re_exclude2} 
	} );
}

if ((AAT::NULL($Session->{extractor})) && 
		((AAT::NOT_NULL($Session->{logs})) || (AAT::NOT_NULL($Session->{file})) 
			|| (AAT::NOT_NULL($session->{csv})))
	&& (($#devices >= 0) && ($#services >= 0) 
	&& ($devices[0] ne "") && ($services[0] ne "")))
{
	use Crypt::PasswdMD5;
	my $output = unix_md5_crypt(time() * rand(99));
	$output =~ s/[\/\&\$\.\?]//g;
	my $cmd = Octopussy::Logs::Extract_Cmd_Line( { 
		devices => \@devices, services =>\@services, 
		begin => "$y1$m1$d1$hour1$min1", end => "$y2$m2$d2$hour2$min2",
		incl1 => $re_include, incl2 => $re_include2,
		excl1 => $re_exclude, excl2 => $re_exclude2, 
		output => "$run_dir/logs_${login}_$output" } );
	$export_filename = "logs_" . join("-", @devices) . "_" . join("-", @services)
    . "_$y1$m1$d1$hour1$min1" . "-$y2$m2$d2$hour2$min2";
	system("$cmd &");
	sleep(1);
	$Session->{logfile} = $output;
	$Response->Redirect("./logs_viewer.asp?extractor=$output");
}

if ($Session->{extractor} eq "done")
{
	my $filename = $Session->{logfile};
	print "Filename: $filename";
	if (AAT::NOT_NULL($Session->{file}))
	{
		AAT::File_Save( { contenttype => "text/txt", 
			input_file => "${run_dir}/logs_${login}_$filename", 
			output_file => "${export_filename}.txt" } );
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
		AAT::File_Save( { contenttype => "text/csv",
     	input_data => $text, output_file => "${export_filename}.csv" } );
	}
	else
	{
		$text = "<table id=\"resultsTable\"><tbody>";
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
				$line =~ s/(\S{150})(\S+?)/$1\n$2/g;
				$text .= "<tr class=\"boxcolor" . ($nb_lines%2+1) . "\"><td>$line</td></tr>";
			}
   		$nb_lines++;
  	}
		close(FILE);
		$last_page = int($nb_lines/$LINES_BY_PAGE) + 1;
		$text .= "</tbody></table>"; 
	}
	($Session->{cancel}, $Session->{extractor}, $Session->{logs}, 
		$Session->{file}, $Session->{csv}, $Session->{zip}) = 
	(undef, undef, undef, undef, undef, undef);
}

if ((AAT::NOT_NULL($Session->{extractor})) && ($Session->{extractor} ne "done"))
{
%>
<WebUI:PageTop title="Logs" onLoad="extract_progress()" />
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
<script type="text/javascript" src="INC/octo_logs_viewer_progressbar.js"> 
</script>
<%
}
else
{
%>
<WebUI:PageTop title="Logs" />
<script type="text/javascript" src="INC/octo_logs_viewer_quick_search.js">
</script>
<%
}
my @restricted_services = Octopussy::Service::List_Used();
$Response->Include("INC/octo_logs_viewer_form.inc", 
	url => "./logs_viewer.asp", restricted_services => \@restricted_services);
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3"><AAT:Label value="Quick Search" style="B" />
	<input id="filter" size="40" style="color:orange" onkeydown="Timer();" />
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
	url => "./logs_viewer.asp?logfile=" . $Session->{logfile}, 
	page => $page, page_last => $last_page)	if ($last_page > 1);
%>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><%= $text %></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3">
<% $Response->Include("INC/octo_page_navigator.inc",
  url => "./logs_viewer.asp?logfile=" . $Session->{logfile},
  page => $page, page_last => $last_page)	if ($last_page > 1);
$Session->{logfile} = undef;
%>
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
