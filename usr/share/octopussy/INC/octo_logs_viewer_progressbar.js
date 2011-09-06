var href = window.location.href;
var started = 0;
var finished = 0;
var loop = 0;

function extract_progress()
{
	$.get('ajax_progress.asp?bin=octo_extractor', function(xml) { Update_Progress(xml); } );
  	loop = setTimeout("extract_progress()", 1000);
}

function Update_Progress(xml)
{
	var xmldoc = $.parseXML(xml);

	var desc = $(xmldoc).find('desc').text();
	var current = $(xmldoc).find('current').text();
	var total = $(xmldoc).find('total').text();
	var match = $(xmldoc).find('match').text();

	if ((desc == "...") && (started))
      	{
        	finished = 1;
        	started = 0;
        	clearTimeout(loop);
        	window.location = "./logs_viewer.asp?extractor=done";       
	}
	else
	{
		progressbar_cancel.innerHTML = '<a href="./logs_viewer.asp?cancel=1">'
			+ '<img border="0" src="AAT/IMG/buttons/bt_remove.png" /></a>';
		started = 1;
		finished = 0;
	}       
	if (finished)
	{
		current = 1;
		total = 1;
		progressbar_cancel.innerHTML = "";       
	}       
      	nb_lines.innerHTML = '<b>'+ match +'</b>';
      	Progress_Bar(current, total);
}
