<%
my %arg = @_;
my $form_number = $arg{form_number} || 0;

my @list = (defined $arg{any} ? ("-ANY-") : ());

$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => ($arg{name} || "msgid"), list => \@list, 
	selected => $arg{selected});
%>
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_msgid = false;

function refresh_selector_msgid()
{
  var selector_service = document.forms[<%= $form_number %>].service;
  var selector_loglevel = document.forms[<%= $form_number %>].loglevel;
  var selector_taxonomy = document.forms[<%= $form_number %>].taxonomy;
	var services_str = '';
	var loglevel_str = '';
	var taxonomy_str = '';
	var selected_str = '<%= $arg{selected} %>';

	if (selector_service)
	{
    for (i = 0; i < selector_service.options.length; i++)
    {
      if (selector_service.options[i].selected == 1)
        services_str = services_str + selector_service.options[i].value + ',';
    }
	}
	if (selector_loglevel)
	{
    for (i = 0; i < selector_loglevel.options.length; i++)
    {
      if (selector_loglevel.options[i].selected == 1)
        loglevel_str = selector_loglevel.options[i].value;
    }
	}
	if (selector_taxonomy)
	{
    for (i = 0; i < selector_taxonomy.options.length; i++)
    {
      if (selector_taxonomy.options[i].selected == 1)
        taxonomy_str = selector_taxonomy.options[i].value;
    }
	}
	http_request_msgid = HttpRequest();
  if (!http_request_msgid)
    { return false; }
  http_request_msgid.onreadystatechange = print_selector_msgid;
  var params = 'services=' + encodeURIComponent(services_str)
    + '&loglevel=' + encodeURIComponent(loglevel_str) 
    + '&taxonomy=' + encodeURIComponent(taxonomy_str)
    + '&selected=' + encodeURIComponent(selected_str);
  http_request_msgid.open('GET', 'ajax_list_msgid.asp?' + params, true);
  http_request_msgid.send(null);	

	return true;
}

function print_selector_msgid()
{
	if (http_request_msgid.readyState == 4)
  {
    if (http_request_msgid.status == 200)
    {
      var xml =  http_request_msgid.responseXML;
      var root = xml.documentElement;
      var items = root.getElementsByTagName('item');
			var selector_msgid = document.forms[<%= $form_number %>].msgid;

			for (i = selector_msgid.options.length-1; i > 0; i--)
        selector_msgid.options[i] = null;
			var msgid = [];
			var selecteds = [];
			for (i = 0; i < items.length; i++) 
			{
				var label = items[i].getAttribute('label');
				msgid.push(label);
				selecteds[label] = items[i].getAttribute('selected');
			}
			count = 1;
			for (e in msgid.sort())
			{
				var value = msgid[e];
				selector_msgid.options[count] = new Option(value);
				if (selecteds[value] == 1)
					selector_msgid.options[count].selected = 1;
				count++;
			}
    }
  }	
}

refresh_selector_msgid();
</script>
