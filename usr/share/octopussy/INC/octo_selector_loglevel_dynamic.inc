<%
my %arg = @_;
my $form_number = $arg{form_number} || 0;

my @types = (defined $arg{any} ? Octopussy::Loglevel::List_And_Any(undef, undef)
	: Octopussy::Loglevel::List(undef, undef));
$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "loglevel"), 
	list => \@types, selected => $arg{selected}, onchange => "refresh_selector_msgid();");
%>
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_loglevel = false;

function refresh_selector_loglevel()
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
  http_request_loglevel = HttpRequest();
  if (!http_request_loglevel)
    { return false; }
  http_request_loglevel.onreadystatechange = print_selector_loglevel;
  http_request_loglevel.open('GET', "ajax_list_loglevel.asp?"
    + "devices=" + devices_str + "&services=" + services_str
    + "&table=" + table_str + "&selected=" + selected_str, true);
  http_request_loglevel.send(null); 

  return true;
}

function print_selector_loglevel()
{
  if (http_request_loglevel.readyState == 4)
  {
    if (http_request_loglevel.status == 200)
    {
      var xml =  http_request_loglevel.responseXML;
      var root = xml.documentElement;
      var items = root.getElementsByTagName('item');
      var selector_loglevel = document.forms[<%= $form_number %>].loglevel;

      for (i = selector_loglevel.options.length-1; i > 0; i--)
        selector_loglevel.options[i] = null;
			var levels = [];
			var labels = [];
      var colors = [];
      var selecteds = [];
      for (i = 0; i < items.length; i++) 
      {
				var level = items[i].getAttribute('level');
        levels.push(level);
				labels[level] = items[i].getAttribute('label');
        colors[level] = items[i].getAttribute('color');
        selecteds[level] = items[i].getAttribute('selected');
      }
    	count = 1;
      for (e in levels.sort().reverse())
      {
				var value = levels[e];
        selector_loglevel.options[count] = new Option(labels[value]);
				selector_loglevel.options[count].style.color = colors[value];
				if (selecteds[value] == 1)
					selector_loglevel.options[count].selected = 1;
        count++;
			}
    }
  } 
}

refresh_selector_loglevel();
</script>
