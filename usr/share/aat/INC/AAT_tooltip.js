var offsetfromcursorX=2 
var offsetfromcursorY=2  

document.write('<div id="tooltip"></div>')

var ie=document.all
var ns6=document.getElementById && !document.all
var enabletip=false

if (ie||ns6)
var tipobj=document.all? document.all["tooltip"] 
	: document.getElementById? document.getElementById("tooltip") : ""


function ietruebody()
{
return (document.compatMode && document.compatMode!="BackCompat")
	? document.documentElement : document.body
}

function tooltip(text, width, color)
{
	if (ns6||ie)
	{
		if (typeof width!="undefined") 
			tipobj.style.width=width+"px"
		if (typeof color!="undefined" && color!="") 
			tipobj.style.backgroundColor=color
		tipobj.innerHTML=text
		enabletip=true
		return false
	}
}

function positiontip(e)
{
	if (enabletip)
	{
		var nondefaultpos=false
		var curX=(ns6)?e.pageX : event.clientX+ietruebody().scrollLeft;
		var curY=(ns6)?e.pageY : event.clientY+ietruebody().scrollTop;
		var winwidth=ie&&!window.opera? ietruebody().clientWidth 
			: window.innerWidth-20
		var winheight=ie&&!window.opera? ietruebody().clientHeight 
			: window.innerHeight-20

		var rightedge=ie&&!window.opera? winwidth-event.clientX-offsetfromcursorX 
			: winwidth-e.clientX-offsetfromcursorX
		var bottomedge=ie&&!window.opera? winheight-event.clientY-offsetfromcursorY 
			: winheight-e.clientY-offsetfromcursorY

		var leftedge=(offsetfromcursorX<0)? offsetfromcursorX*(-1) : -1000

		if (rightedge<tipobj.offsetWidth)
		{
			tipobj.style.left=curX-tipobj.offsetWidth+"px"
			nondefaultpos=true
		}
		else if (curX<leftedge)
			tipobj.style.left="5px"
		else
		{
			tipobj.style.left=curX+offsetfromcursorX+"px"
		}

		if (bottomedge<tipobj.offsetHeight)
		{
			tipobj.style.top=curY-tipobj.offsetHeight-offsetfromcursorY+"px"
			nondefaultpos=true
		}
		else
			tipobj.style.top=curY+offsetfromcursorY+"px"
		tipobj.style.visibility="visible"
	}
}

function hidetooltip()
{
	if (ns6||ie)
	{
		enabletip=false
		tipobj.style.visibility="hidden"
		tipobj.style.left="-1000px"
		tipobj.style.backgroundColor=''
		tipobj.style.width=''
	}
}

document.onmousemove=positiontip
