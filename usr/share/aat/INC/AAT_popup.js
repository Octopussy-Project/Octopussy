function popup(mylink, name)
{
	if (! window.focus)return true;

	var href;
	var width=500;
	var height=200;
	var top=(screen.height-height)/2;
	var left=(screen.width-width)/2;

	if (typeof(mylink) == 'string')
		href=mylink;
	else
		href=mylink.href;
	window.open(href, name,"top="+top+",left="+left+",width="+width+",height="+height+",resizable=yes");
	
	return false;
}
