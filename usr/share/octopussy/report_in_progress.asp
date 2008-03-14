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
	$reportname = $1;
	$reporttype = $2;
}
%>
<AAT:PageTop onLoad="report_progress()" />
<script type="text/javascript">
var http_request = false;
var href = window.location.href;
var cmd = href.substr(href.indexOf("="));
var bars = 40;
var started = 0;
var loop = 0;

function report_progress()
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
			var percent = root.getElementsByTagName('percent')[0].firstChild.data;
			cbars = current * bars / total;
      progressbar_desc.innerHTML = desc;
			progressbar_progress.innerHTML = current + "/" + total + "(" + percent + "%)";
			var bar = root.getElementsByTagName('desc')[0].firstChild.data + "<table border=1 bgcolor=#E7E7E7><tr>";
			
			for (var i = 0; i < cbars; i++)
			{
				var color = 99 - (i*50/bars);
      	bar+= "<td width=10 height=20 bgcolor=\"rgb(0,0," + color + ")\"></td>";
			}
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
<table align="center">
	<tr><td>
	<AAT:ProgressBar title="Report Generation $reportname" 
		msg="Report Generation: $reportname"
		cancel="./report_cancel.asp?cmd=$url_cmd" /> 
	</td></tr>
</table>
<AAT:PageBottom />
