function targetopener(mylink, closeme, closeonly)
{
	if (! (window.focus && window.opener)) return true;
	window.opener.focus();
	if (! closeonly) window.opener.location.href=mylink.href;
	if (closeme) window.close();
	
	return false;
}

window.focus();
