<%
my $run_dir = Octopussy::Directory("running");
my $max_lines = Octopussy::Parameter("logs_viewer_max_lines");
my $msg_max_lines = sprintf(AAT::Translation("_MSG_REACH_MAX_LINES"), $max_lines);
my $msg_nb_lines = AAT::Translation("_MSG_NB_LINES");
my $url = "./logs_viewer.asp";
my $nb_lines = 0;
my $text = "";

my @devices = AAT::ARRAY($Session->{device});
my @services = AAT::ARRAY($Session->{service});

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
	my $dev_str = "--device " . join(" --device ", @devices);
	my $serv_str = "--service " . join(" --service ", @services);
	my $filename = "logs_" . join("-", @devices) . "_" . join("-", @services)
    . "_$y1$m1$d1$hour1$min1-$y2$m2$d2$hour2$min2";
	my $cmd = "/usr/sbin/octo_extractor $dev_str $serv_str --taxonomy \"-ANY-\""
		. " --begin $y1$m1$d1$hour1$min1 --end $y2$m2$d2$hour2$min2" 
		. " --include1 '$re_include' --include2 '$re_include2'"
		. " --exclude1 '$re_exclude' --exclude2 '$re_exclude2'"
		. " --output $run_dir/$filename";
	system("$cmd &");
	sleep(1);
  $Response->Redirect("./logs_viewer.asp?extractor=$filename");
}

if (AAT::NOT_NULL($Session->{logfile}))
{
	my $filename = $Session->{logfile};
	if (AAT::NOT_NULL($Session->{file}))
	{
		AAT::File_Save( { contenttype => "text/txt", 
			input_file => "$run_dir/$filename", 
			output_file => "${filename}.txt" } );
	}
	elsif (AAT::NOT_NULL($Session->{csv}))
	{
		open(FILE, "< $run_dir/$filename");
		while (<FILE>)
		{
   		$text .= "$1;$2;$3\n" 
				if ($_ =~ /^(\w{3} \s?\d{1,2} \d\d:\d\d:\d\d) (\S+) (.+)$/);
  	}
		close(FILE);
		AAT::File_Save( { contenttype => "text/csv",
     	input_data => $text, output_file => "${filename}.csv" } );
	}
	else
	{
		$text = "<table id=\"resultsTable\"><tbody>";
		open(FILE, "< /var/run/octopussy/$filename");
    while (<FILE>)
    {
			my $line = $Server->HTMLEncode($_);
			$line =~ s/($re_include)/<font color="red"><b>$1<\/b><\/font>/g	
				if (AAT::NOT_NULL($re_include));
			$line =~ s/($re_include2)/<font color="blue"><b>$1<\/b><\/font>/g
				if (AAT::NOT_NULL($re_include2));
			$line =~ s/(\S{150})(\S+?)/$1\n$2/g;
			$text .= "<tr class=\"boxcolor" . ($nb_lines%2+1) . "\"><td>$line</td></tr>";
   		$nb_lines++;
  	}
		close(FILE);
		$text .= "</tbody></table>"; 
	}
	($Session->{extractor}, $Session->{logfile}, $Session->{cancel}, 
	$Session->{logs}, $Session->{file}, $Session->{csv}, $Session->{zip}) =
  	(undef, undef, undef, undef, undef, undef, undef);
}

my @used_services = Octopussy::Service::List_Used();

if (AAT::NOT_NULL($Session->{extractor}))
{
%>
<WebUI:PageTop title="Logs" onLoad="extract_progress()" />
<script type="text/javascript">
var http_request = false;
var href = window.location.href;
var bars = 40;
var started = 0;
var loop = 0;

function extract_progress()
{
  http_request = false;
  if (window.XMLHttpRequest)
  { // Mozilla, Safari,...
    http_request = new XMLHttpRequest();
    if (http_request.overrideMimeType)
      { http_request.overrideMimeType('text/xml'); }
  }
  else if (window.ActiveXObject)
  { // IE
    try { http_request = new ActiveXObject("Msxml2.XMLHTTP"); }
    catch (e)
    {
      try { http_request = new ActiveXObject("Microsoft.XMLHTTP"); }
      catch (e) {}
    }
  }
  if (!http_request)
    { return false; }
  http_request.onreadystatechange = Update_Progress;
  http_request.open('GET', "ajax_extract_progress.asp", true);
  http_request.send(null);
  loop = setTimeout("extract_progress()", 1000);
}

function Update_Progress()
{
  if (http_request.readyState == 4)
  {
    if (http_request.status == 200)
    {
      var xml =  http_request.responseXML;
      var root = xml.documentElement;
      if ((!root.getElementsByTagName('total')[0].firstChild) && (started))
      {
        clearTimeout(loop);
        window.location = "./logs_viewer.asp?logfile=<%= $Session->{extractor} %>";
      }
      else
      {
        started = 1;
      }
      var current = root.getElementsByTagName('current')[0].firstChild.data;
      var total = root.getElementsByTagName('total')[0].firstChild.data;
      var percent = root.getElementsByTagName('percent')[0].firstChild.data;
      var cbars = current * bars / total;
			progressbar_cancel.innerHTML = "<a href=\"./logs_viewer.asp?cancel=<%= $Session->{extractor} %>\">Cancel</a>";
			var progress_str = current + "/" + total + " (" + percent + "%)";
      progressbar_progress.innerHTML = progress_str;

      var bar = "<table border=1 bgcolor=#E7E7E7><tr>";
      for (var i = 0; i < cbars; i++)
      {
        var color = 99 - (i*50/bars);
        bar+= "<td width=10 height=20 bgcolor=\"rgb(0,0," + color + ")\"></td>";      }
      for (var i = cbars; i < bars; i++)
      {
        bar+= "<td width=10 height=20 bgcolor=\"white\"></td>";
      }
      bar+= "</tr></table>";
      progressbar_bar.innerHTML = bar;
    }
  }
}
</script>
<%
}
else
{
%>
<WebUI:PageTop title="Logs" />

<script language="javascript">

var nb_lines = 0;
var timeoutid = 0;

function Timer()
{
	clearTimeout(timeoutid);
	timeoutid = setTimeout("FilterData()", 2000); 
}

function FilterData() 
{
	clearTimeout(timeoutid); 
	nb_lines = 0;
	filter = document.getElementById("filter").value;
	if (filter.length > 1) 
	{ // at least 2 chars		
		rows = document.getElementById("resultsTable").tBodies[0].rows;
		var regex = new RegExp("<\/?(font|b).*?>", "gi");
		var search = new RegExp("("+filter+")", "g");
		for (i = 0; i < rows.length; i++) 
		{
			var cell = rows[i].cells[0];
			var str = cell.innerHTML;
			var newstr = str.replace(regex, "");
			newtext = newstr.replace(search,"<font color=\"orange\"><b>$1</b></font>");
			if (newtext == newstr)
			{
				rows[i].style.display = "none";
			}
			else
			{
				nb_lines++;
        rows[i].style.display = ""; 
				cell.innerHTML = newtext;
			}
		}
		spanNumber = document.getElementById("nb_lines");
		spanNumber.innerHTML = "<b>" + nb_lines + "</b>";
	}
	else
	{
		for (i = 0; i < rows.length; i++)
    {
			nb_lines++;
      rows[i].style.display = "";
		}
	}
}
</script>
<%
}
%>
<AAT:Form action="$url">
<AAT:Box align="C" title="_LOGS_VIEWER" icon="buttons/bt_search">
<AAT:BoxRow>
  <AAT:BoxCol cspan="2">
  <AAT:Form action="$url">
  <AAT:Box align="C">
	<AAT:BoxRow>
    <AAT:BoxCol cspan="2">
		<AAT:Inc file="octo_selector_search_template" selected="" /></AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow>
    <AAT:BoxCol>
    <AAT:Entry name="template" value="enter your template name" size="40" />
    </AAT:BoxCol>
    <AAT:BoxCol><AAT:Form_Submit value="_SAVE_AS_TEMPLATE" /></AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:Form>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Box align="C">
	<AAT:BoxRow>
		<AAT:BoxCol align="C">
		<AAT:Button name="device" /><br>
  	<AAT:Label value="_DEVICES" align="R" style="B" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
    	unknown="1" multiple="1" size="5" selected=\@devices /></AAT:BoxCol>
  	<AAT:BoxCol align="C">
		<AAT:Button name="service" /><br>
  	<AAT:Label value="_SERVICES" align="R" style="B" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
    	unknown="1" multiple="1" size="5" device=\@devices selected=\@services 
			restricted_services=\@used_services /></AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Selector_DateTime_Simple name="dt" start_year="2000" url="$url"
    selected="$dt"
    selected1="$d1/$m1/$y1/$hour1/$min1" selected2="$d2/$m2/$y2/$hour2/$min2" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2">
	<AAT:Box align="C">
	<AAT:BoxRow>
	<AAT:BoxCol align="R">
	<AAT:Button name="msg_ok" tooltip="_REGEXP_INC"/></AAT:BoxCol>
	<AAT:BoxCol>
		<AAT:Entry name="re_include" value="$re_include" 
			size="50" style="color:red" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude" value="$re_exclude" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
	<AAT:Button name="msg_ok" tooltip="_REGEXP_INC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_include2" value="$re_include2" 
			size="50" style="color:blue" />
	</AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Button name="msg_critical" tooltip="_REGEXP_EXC"/></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="re_exclude2" value="$re_exclude2" size="50" />
	</AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Form_Submit name="logs" value="_GET_LOGS" />
	<AAT:Form_Submit name="file" value="_DOWNLOAD_FILE" />
	<AAT:Form_Submit name="csv" value="_DOWNLOAD_CSV_FILE" />
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3"><AAT:Label value="Quick Search" style="B" />
	<input id="filter" size="40" style="color:orange" onkeydown="Timer();" />
	<AAT:Label value="$msg_nb_lines" style="B"/>
	<span id="nb_lines"><b><%= $nb_lines %></b></span>
<%if ($nb_lines >= $max_lines)
	{ %><AAT:Message level="1" msg="$msg_max_lines" /><% } %>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><div id="progressbar_cancel"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_bar"></div></AAT:BoxCol>
	<AAT:BoxCol><div id="progressbar_progress"></div></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><%= $text %></AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
<WebUI:PageBottom />
