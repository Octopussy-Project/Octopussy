<%
my %arg = @_;
my $form_number = $arg{form_number} || 0;

my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, Octopussy::Taxonomy::List());

$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => ($arg{name} || "taxonomy"), list => \@list, 
	selected => $arg{selected});
%>
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_taxonomy = false;

function refresh_selector_taxonomy()
{
	var selector_device = document.forms[<%= $form_number %>].device;
  var selector_service = document.forms[<%= $form_number %>].service;
	var selector_table = document.forms[<%= $form_number %>].table;
	var devices_str = '';
	var services_str = '';
	var table_str = '';
	var selected_str = '<%= $arg{selected} %>';

	if (selector_device || selector_service)
	{
		for (i = 0; i < selector_device.options.length; i++)
    {
      if (selector_device.options[i].selected == 1)
        devices_str = devices_str + selector_device.options[i].value + ',';
    }
    for (i = 0; i < selector_service.options.length; i++)
    {
      if (selector_service.options[i].selected == 1)
        services_str = services_str + selector_service.options[i].value + ',';
    }
	}
	if (selector_table)
	{
		for (i = 0; i < selector_table.options.length; i++)
    {
      if (selector_table.options[i].selected == 1)
        table_str = selector_table.options[i].value;
    }
	}
	http_request_taxonomy = HttpRequest();
  if (!http_request_taxonomy)
    { return false; }
  http_request_taxonomy.onreadystatechange = print_selector_taxonomy;
  http_request_taxonomy.open('GET', "ajax_list_taxonomy.asp?"
		+ "devices=" + devices_str + "&services=" + services_str
		+ "&table=" + table_str + "&selected=" + selected_str, true);
  http_request_taxonomy.send(null);	

	return true;
}

function print_selector_taxonomy()
{
	if (http_request_taxonomy.readyState == 4)
  {
    if (http_request_taxonomy.status == 200)
    {
      var xml =  http_request_taxonomy.responseXML;
      var root = xml.documentElement;
      var items = root.getElementsByTagName('item');
			var selector_taxonomy = document.forms[<%= $form_number %>].taxonomy;

			for (i = selector_taxonomy.options.length-1; i > 0; i--)
        selector_taxonomy.options[i] = null;
			var taxo = [];
			var colors = [];
			var selecteds = [];
			for (i = 0; i < items.length; i++) 
			{
				var label = items[i].getAttribute('label');
				taxo.push(label);
				colors[label] = items[i].getAttribute('color');
				selecteds[label] = items[i].getAttribute('selected');
			}
			count = 1;
			for (e in taxo.sort())
			{
				var value = taxo[e];
				selector_taxonomy.options[count] = new Option(value);
				selector_taxonomy.options[count].style.color = colors[value];
				if (selecteds[value] == 1)
					selector_taxonomy.options[count].selected = 1;
				count++;
			}
    }
  }	
}

refresh_selector_taxonomy();
</script>
