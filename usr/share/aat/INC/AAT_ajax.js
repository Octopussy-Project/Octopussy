function HttpRequest()
{
	var http_request = false;

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

	return (http_request);
}
