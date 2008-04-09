var http_request = false;
var href = window.location.href;
var started = 0;
var finished = 0;
var loop = 0;

function extract_progress()
{
  http_request = HttpRequest("Update_Progress", "ajax_extract_progress.asp");
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
        finished = 1;
        started = 0;
        clearTimeout(loop);
        window.location = "./logs_viewer.asp?extractor=done";       
			}
			else
			{
				started = 1;
				finished = 0;
			}       
			var current = root.getElementsByTagName('current')[0].firstChild.data;
			var total = root.getElementsByTagName('total')[0].firstChild.data;
			var match = root.getElementsByTagName('match')[0].firstChild.data;
			if (finished)
			{
				current = 1;
				total = 1;
				progressbar_cancel.innerHTML = "";       
			}       
			else       
			{
        progressbar_cancel.innerHTML = '<a href="./logs_viewer.asp?cancel=1"><img border="0" src="AAT/IMG/buttons/bt_remove.png" /></a>';
      }
      nb_lines.innerHTML = '<b>'+ match +'</b>';
      Progress_Bar(current, total);
    }
  }
}
