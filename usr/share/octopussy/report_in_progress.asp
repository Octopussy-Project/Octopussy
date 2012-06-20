<%
my $cmd = $Request->QueryString("cmd");
my $url_cmd = $Server->URLEncode($cmd);
my $reportname = $cmd;
my $reporttype = undef;

($reportname, $reporttype) = ($1, $2)
	if ($reportname =~ /.+\/((.+)-\d{8}-\d{4}.+)?"$/);
$reportname = $Server->HTMLEncode($reportname);
%>
<AAT:PageTop title="_REPORT_IN_PROGRESS" onLoad="report_progress()" />
<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
<script type="text/javascript">
var href = window.location.href;
var cmd = href.substr(href.indexOf("="));
var started = 0;
var finished = 0;
var loop = 0;

function report_progress()
{
	$.get('ajax_progress.asp?bin=octo_reporter', function(xml) { Update_Progress(xml); } );
	loop = setTimeout("report_progress()", 1000);
}

function Update_Progress(xml)
{
	var xmldoc = $.parseXML(xml);

	var desc = $(xmldoc).find('desc').text();
	var current = $(xmldoc).find('current').text();
	var total = $(xmldoc).find('total').text();

	if ((desc == "...") && (started))
	{
		finished = 1;
        	started = 0;
		clearTimeout(loop);
  	  	window.location="./report_show.asp?report_type=<%= $reporttype %>&filename=<%= $reportname %>";
  	}
	else
	{
		progressbar_cancel.innerHTML = '<a href="./report_cancel.asp">'
          		+ '<img border="0" src="AAT/IMG/buttons/bt_remove.png" /></a>';
		started = 1;
		finished = 0;
	}
	if (finished)
      	{
        	current = 1;
        	total = 1;
        	progressbar_cancel.innerHTML = "";
      	}
      	progressbar_desc.innerHTML = desc;
	Progress_Bar(current, total);
}
</script>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="3">
	<AAT:Label value="Report Generation: $reportname" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol cspan="3" align="C"><div id="progressbar_desc"></div></AAT:BoxCol> 
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><div id="progressbar_cancel"></div></AAT:BoxCol>
  <AAT:BoxCol><div id="progressbar_bar"></div></AAT:BoxCol>
  <AAT:BoxCol><div id="progressbar_progress"></div></AAT:BoxCol>
</AAT:BoxRow>	
</AAT:Box>
<AAT:PageBottom />
