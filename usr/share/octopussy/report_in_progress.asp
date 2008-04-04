<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my $cmd = $Request->QueryString("cmd");
my $url_cmd = $Server->URLEncode($cmd);
my $reportname = $cmd;
my $reporttype = undef;
if ($reportname =~ /.+\/((.+)-\d{8}-\d{4}.+)?"$/)
{
	($reportname, $reporttype) = ($1, $2);
}
%>
<AAT:PageTop onLoad="report_progress()" />
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<AAT:JS_Inc file="AAT/INC/AAT_progressbar.js" />
<script type="text/javascript">
var http_request = false;
var href = window.location.href;
var cmd = href.substr(href.indexOf("="));
var started = 0;
var loop = 0;

function report_progress()
{
  http_request = HttpRequest();
  if (!http_request)
    { return false; }
  http_request.onreadystatechange = Update_Progress;
  http_request.open('GET', "ajax_report_progress.asp?cmd=" + cmd, true);
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
			if ((!root.getElementsByTagName('desc')[0].firstChild) && (started))
			{
				clearTimeout(loop);
  	  	window.location="./report_show.asp?report_type=<%= $reporttype %>&filename=<%= $reportname %>";
  		}
			else
			{
				started = 1;
			}
      var desc = root.getElementsByTagName('desc')[0].firstChild.data;
			var current = root.getElementsByTagName('current')[0].firstChild.data;
			var total = root.getElementsByTagName('total')[0].firstChild.data;
      progressbar_desc.innerHTML = desc;
			Progress_Bar(current, total);
    }
  }
}
</script>
<table align="center">
	<tr><td>
	<AAT:ProgressBar title="Report Generation $reportname" 
		msg="Report Generation: $reportname"
		cancel="./report_cancel.asp?cmd=$url_cmd" /> 
	</td></tr>
</table>
<AAT:PageBottom />
