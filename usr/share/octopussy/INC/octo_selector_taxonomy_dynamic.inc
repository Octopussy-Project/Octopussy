<%
my %arg = @_;

my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, Octopussy::Taxonomy::List());

my $str_any = AAT::Translation("-- ANY --");
%>
<select<%= $select_options %> id="taxonomy" name="taxonomy"
        onchange="refresh_selector_msgid();">
</select>
<script type="text/javascript">

function refresh_selector_taxonomy()
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

	$.get('ajax_list_taxonomy.asp?' + params, function(xml) { print_selector_taxonomy(xml); } );

	return true;
}

function print_selector_taxonomy(xml)
{
	var xmldoc = $.parseXML(xml);
        var items = $(xmldoc).find('item');

	$('#taxonomy option').remove();
	$('#taxonomy').append($('<option></option>').val('-ANY-').html('<%= $str_any %>'));

	var taxo = [];
	var colors = [];
	var selecteds = [];

	$(items).each( function (i)
		{	
		var label = items[i].getAttribute('label');
		taxo.push(label);
		colors[label] = items[i].getAttribute('color');
		selecteds[label] = items[i].getAttribute('selected');
		} );
			
	for (e in taxo.sort())
	{
		var value = taxo[e];
		$('#taxonomy').append($('<option></option>').val(value).html(value));
		$('#taxonomy option[value="' + value + '"]').css('color', colors[value]);
		if (selecteds[value] == 1)
			$('#taxonomy option[value="' + value + '"]').attr('selected', 'selected');
	}
}

refresh_selector_taxonomy();
</script>
