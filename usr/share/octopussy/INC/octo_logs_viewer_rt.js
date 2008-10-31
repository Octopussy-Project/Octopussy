var nb_lines = 0;
var timeout = 300;
var timeoutid = 0;

function RT_Init()
{
	timeout = 300;
  clearTimeout(timeoutid);
	alert("toto");
  timeoutid = setTimeout("RT_Refresh()", 1000);
}

function RT_Refresh()
{
	spanTimeout = document.getElementById("timeout");
  spanTimeout.innerHtml = timeout;
	timeout--;
	if (timeout == 0)
		clearTimeout(timeoutid);
} 
