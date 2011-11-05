<%
my %arg = @_;
my @list = (defined $arg{any} ? ("-ANY-") : ());
my $str_any = AAT::Translation("-- ANY --");
%>
<select<%= $select_options %> id="msgid" name="msgid">
</select>
<script type="text/javascript">

function refresh_selector_msgid()
{
	var selector_service = $('#service');
  	var selector_loglevel = $('#loglevel');
  	var selector_taxonomy = $('#taxonomy');
	var services_str = '';
	var loglevel_str = '';
	var taxonomy_str = '';
	var selected_str = '<%= $arg{selected} %>';

	if (selector_service)
	{
		$('#service option:selected').each( function ()
        	{ services_str = services_str + $(this).val() + ','; } );
   	}
	if (selector_loglevel)
	{
		$('#loglevel option:selected').each( function ()
        	{ loglevel_str = loglevel_str + $(this).val() + ','; } );
   	}
	if (selector_taxonomy)
	{
		$('#taxonomy option:selected').each( function ()
       		{ taxonomy_str = taxonomy_str + $(this).val() + ','; } );
   	}
  
  var params = 'services=' + encodeURIComponent(services_str)
    + '&loglevel=' + encodeURIComponent(loglevel_str) 
    + '&taxonomy=' + encodeURIComponent(taxonomy_str)
    + '&selected=' + encodeURIComponent(selected_str);

	$.get('ajax_list_msgid.asp?' + params, function(xml) { print_selector_msgid(xml); } );

	return true;
}

function print_selector_msgid(xml)
{
	var xmldoc = $.parseXML(xml);
        var items = $(xmldoc).find('item');

	$('#msgid option').remove();
	$('#msgid').append($('<option></option>').val('-ANY-').html('<%= $str_any %>'));
	var msgid = [];
	var selecteds = [];

	$(items).each( function (i)
		{
			var label = items[i].getAttribute('label');
			msgid.push(label);
			selecteds[label] = items[i].getAttribute('selected');
		} );
	
	for (e in msgid.sort())
	{
		var value = msgid[e];
		$('#msgid').append($('<option></option>').val(value).html(value));
		if (selecteds[value] == 1)
			$('#msgid option[value="' + value + '"]').attr('selected', 'selected');
	}
}

refresh_selector_msgid();
</script>
