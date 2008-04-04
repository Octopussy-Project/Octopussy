function Progress_Bar(current, total)
{
	var bars = 50;
	var cbars = parseInt(current * bars / total);
	var percent = parseInt(current / total * 100);

	var s = '<table border="2" cellspacing="0" bgcolor="#E7E7E7"><tr>';
 	for (var i = 0; i < cbars; i++)
 	{
  	var color = parseInt(99 - (i*50/bars));
   	s += '<td width="5" height="20" bgcolor="rgb(0,0,'+color+')"></td>';
	}
	for (var i = cbars; i < bars; i++)
  {
  	s += '<td width="5" height="20" bgcolor="white"></td>';
 	}
	s += '</tr></table>';
	pb_bar = document.getElementById("progressbar_bar");
	pb_progress = document.getElementById("progressbar_progress");
	pb_bar.innerHTML = s;
	pb_progress.innerHTML = current+"/"+ total+" ("+percent+"%)";
}
