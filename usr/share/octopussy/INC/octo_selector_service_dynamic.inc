<% 
my %arg = @_; 
my $form_number = $arg{form_number} || 0;
my $select_options = (defined $arg{multiple} ? " multiple" : "")
  . (defined $arg{size} ? " size=$arg{size}" : "");
my %selected = ();
foreach my $s (ARRAY($arg{selected}))
  { $selected{$s} = 1; }

my $str_any = AAT::Translation("-ANY-");
my $str_unknown = "<" . AAT::Translation("_UNKNOWN") . ">";
%>
<select<%= $select_options %> name="service" 
	onchange="refresh_selector_loglevel();refresh_selector_taxonomy();refresh_selector_msgid();">
</select>
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_service = false;

function refresh_selector_service()
{
  var selector_device = document.forms[<%= $form_number %>].device;
  var devices_str = '';
  var selected_str = '';
  
  <%
  if (defined $arg{selected})
  {%>
  selected_str = '<% print join(",", @{$arg{selected}}); %>';<% 
  }%>

  for (i = 0; i < selector_device.options.length; i++)
  {
    if (selector_device.options[i].selected == 1)
      devices_str = devices_str + selector_device.options[i].value + ',';
  }
  
  http_request_service = HttpRequest();
  if (!http_request_service)
    { return false; }
  http_request_service.onreadystatechange = print_selector_service;
  var params = 'devices=' + encodeURIComponent(devices_str) 
    + '&selected=' + encodeURIComponent(selected_str);
  http_request_service.open('GET', 'ajax_list_service.asp?' + params, true);
  http_request_service.send(null);
	
  return true;
}

function print_selector_service()
{
  if (http_request_service.readyState == 4)
  {
    if (http_request_service.status == 200)
    {
      var xml =  http_request_service.responseXML;
      var root = xml.documentElement;
      var items = root.getElementsByTagName('item');
      var selector_service = document.forms[<%= $form_number %>].service;

      for (i = selector_service.options.length-1; i >= 0; i--)
        selector_service.options[i] = null;
			selector_service.options[0] = new Option("<%= $str_any %>", "-ANY-");
<%			
if ($selected{"-ANY-"})
{
  %>selector_service.options[0].selected = 1;<%
}
my $start = 1;
if (defined $arg{unknown})
{
%>selector_service.options[<%= $start %>] = new Option("<%= $str_unknown %>", "Unknown");<%
	if ($selected{"Unknown"})
	{
	%>selector_service.options[<%= $start %>].selected = 1;<%
	}
	$start++;
}
%>
      for (i = 0; i < items.length; i++) 
      {
        var label = items[i].getAttribute('label');
				var selected = items[i].getAttribute('selected');
        selector_service.options[i+<%= $start %>] = new Option(label, label);
				if (selected == 1)
          selector_service.options[i+<%= $start %>].selected = 1;
      }
    }
  } 
}

refresh_selector_service();
</script>
