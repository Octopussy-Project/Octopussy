<%
my %arg = @_;

my @types = (defined $arg{any} ? Octopussy::Loglevel::List_And_Any(undef, undef)
	: Octopussy::Loglevel::List(undef, undef));

my $str_any = AAT::Translation("-- ANY --");
#$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "loglevel"), 
#	list => \@types, selected => $arg{selected}, onchange => "refresh_selector_msgid();");
%>
<select<%= $select_options %> id="loglevel" name="loglevel"
        onchange="refresh_selector_msgid();">
</select>
<script type="text/javascript">

function refresh_selector_loglevel()
{
  var selector_device = $('#device');
  var selector_service = $('#service');
  var selector_table = $('#table');
  var devices_str = '';
  var services_str = '';
  var table_str = '';
  var selected_str = '<%= $arg{selected} %>';

	if (selector_device || selector_service)
  	{
	$('#device option:selected').each( function ()
                { devices_str = devices_str + $(this).text() + ','; } );
	$('#service option:selected').each( function ()
                { services_str = services_str + $(this).text() + ','; } );
	}
	if (selector_table)
  	{
	$('#table option:selected').each( function ()
                { table_str = table_str + $(this).text() + ','; } );
  	}

  var params = 'devices=' + encodeURIComponent(devices_str) 
    + '&services=' + encodeURIComponent(services_str)
    + '&table=' + encodeURIComponent(table_str) 
    + '&selected=' + encodeURIComponent(selected_str);

	$.get('ajax_list_loglevel.asp?' + params, function(xml) { print_selector_loglevel(xml); } );
	
  return true;
}

function print_selector_loglevel(xml)
{
	var xmldoc = $.parseXML(xml);
        var items = $(xmldoc).find('item');

	$('#loglevel option').remove();
	$('#loglevel').append($('<option></option>').val('-ANY-').html('<%= $str_any %>'));
	var levels = [];
	var labels = [];
      	var colors = [];
      	var selecteds = [];
      
	$(items).each( function (i)
      		{
		var level = items[i].getAttribute('level');
        	levels.push(level);
		labels[level] = items[i].getAttribute('label');
        	colors[level] = items[i].getAttribute('color');
        	selecteds[level] = items[i].getAttribute('selected');
      		} );
      
	for (e in levels.sort().reverse())
      	{
		var value = levels[e];
		$('#loglevel').append($('<option></option>').val(labels[value]).html(labels[value]));
		$('#loglevel option[value="' + labels[value] + '"]').css('color', colors[value]); 
		if (selecteds[value] == 1)
			$('#loglevel option[value="' + labels[value] + '"]').attr('selected', 'selected');
	}
}

refresh_selector_loglevel();
</script>
