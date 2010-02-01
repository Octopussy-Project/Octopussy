<%
my $cmd = $Request->QueryString("cmd");
my $url_cmd = $Server->URLEncode($cmd);
my $reportname = $cmd;
my $reporttype = undef;

($reportname, $reporttype) = ($1, $2)
	if ($reportname =~ /.+\/((.+)-\d{8}-\d{4}.+)?"$/);
%>
<AAT:PageTop title="_REPORT_IN_PROGRESS" onLoad="report_progress()" />
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
<script type="text/javascript">
var http_request = false;
var href = window.location.href;
var cmd = href.substr(href.indexOf("="));
var started = 0;
var finished = 0;
var loop = 0;

function report_progress()
{
  http_request = HttpRequest("Update_Progress", 
		"ajax_progress.asp?bin=octo_reporter");
  if (!http_request)
    { return false; }
  http_request.onreadystatechange = Update_Progress;
  http_request.open('GET', "ajax_progress.asp?bin=octo_reporter", true);
  http_request.send(null);
	loop = setTimeout("report_progress()", 1000);
}

function Update_Progress()
{
	if (http_request.readyState == 4)
  {
    if (http_request.status == 200)
    {
      var xml =  http_request.responseXML;
			var root = xml.documentElement;
			if ((root.getElementsByTagName('desc')[0].firstChild.data == "...") 
				&& (started))
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
      var desc = root.getElementsByTagName('desc')[0].firstChild.data;
			var current = root.getElementsByTagName('current')[0].firstChild.data;
			var total = root.getElementsByTagName('total')[0].firstChild.data;
			if (finished)
      {
        current = 1;
        total = 1;
        progressbar_cancel.innerHTML = "";
      }
      progressbar_desc.innerHTML = desc;
			Progress_Bar(current, total);
    }
  }
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
