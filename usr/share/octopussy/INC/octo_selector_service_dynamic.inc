<% 
my %arg = @_; 
my $form_number = $arg{form_number} || 0;
my $select_options = (defined $arg{multiple} ? " multiple" : "")
  . (defined $arg{size} ? " size=$arg{size}" : "");

my $str_any = AAT::Translation("-ANY-");
my $str_unknown = "<" . AAT::Translation("_UNKNOWN") . ">";
my %selected = ();
foreach my $s (AAT::ARRAY($arg{selected}))
  { $selected{$s} = 1; }

my @services = (AAT::NOT_NULL($arg{restricted_services}) 
	? AAT::ARRAY($arg{restricted_services}) : Octopussy::Service::List());
%>
<select<%= $select_options %> name="service" 
	onchange="refresh_selector_loglevel();refresh_selector_taxonomy();">
<% 
$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "-ANY-",
  selected => ($selected{"-ANY-"} ? "selected" : ""), label => $str_any);
if (defined $arg{unknown})
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "Unknown",
    selected => ($selected{"Unknown"} ? "selected" : ""), label => $str_unknown);
}
foreach my $s (@services)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $s,
    selected => ($selected{$s} ? "selected" : ""), label => $s);
}
%>
</select>
<%
my ($i, $i2) = (0, 0);
my @services = (AAT::NOT_NULL($arg{restricted_services})
  ? AAT::ARRAY($arg{restricted_services}) : Octopussy::Service::List());
my (@dg_list, @d_list) = ((), ());
if (AAT::NOT_NULL($arg{device}))
{
  foreach my $e (AAT::ARRAY($arg{device}))
    { push(@dg_list, $1) if ($e =~ /^group (.+)$/); }
}
else
  { @dg_list = Octopussy::DeviceGroup::List(); }
if (AAT::NOT_NULL($arg{device}))
{
  foreach my $e (AAT::ARRAY($arg{device}))
    { push(@d_list, $e) if ($e !~ /^group /); }
}
else
  { @d_list = Octopussy::Device::List(); }
%>
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_service = false;

function refresh_selector_service()
{
  var selector_device = document.forms[<%= $form_number %>].device;
  var devices_str = '';
	var selected_str = '<% print join(",", @{$arg{selected}}); %>';

  for (i = 0; i < selector_device.options.length; i++)
  {
    if (selector_device.options[i].selected == 1)
      devices_str = devices_str + selector_device.options[i].value + ',';
  }
  http_request_service = HttpRequest();
  if (!http_request_service)
    { return false; }
  http_request_service.onreadystatechange = print_selector_service;
  http_request_service.open('GET', "ajax_list_service.asp?"
    + "devices=" + devices_str + "&selected=" + selected_str, true);
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

      for (i = selector_service.options.length-1; i > 1; i--)
        selector_service.options[i] = null;
      for (i = 0; i < items.length; i++) 
      {
        var label = items[i].getAttribute('label');
				var selected = items[i].getAttribute('selected');
        selector_service.options[i+2] = new Option(label, label);
				if (selected == 1)
          selector_service.options[i+2].selected = 1;
      }
    }
  } 
}

refresh_selector_service();
</script>
