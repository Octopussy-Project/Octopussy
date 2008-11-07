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
	onchange="refresh_selector_taxonomy();">
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
var selector_device = document.forms[<%= $form_number %>].device;
var selector_service = document.forms[<%= $form_number %>].service;
var nb_device = selector_device.options.length;
var service = new Array(nb_device);
for (i = 0; i < nb_device; i++)
	service[i] = new Array();

service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_any %>", "-ANY-");
<%
if (defined $arg{unknown})
{ %> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_unknown %>", "Unknown"); 
<% }
foreach my $s (@services)
{	%> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $s %>","<%= $s %>"); 
<% }
$i++;

foreach my $d (sort @dg_list)
{
	my $i2 = 0;
	%>
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_any %>", "-ANY-");<%
	if (defined $arg{unknown})
	{ %> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_unknown %>", "Unknown");<% 		}	
	my %service = ();
	my @services = ();
	foreach my $dg_s (Octopussy::DeviceGroup::Services($d))
		{ $service{$dg_s} = 1; }
	my @res_services = (AAT::NOT_NULL($arg{restricted_services})
  	? AAT::ARRAY($arg{restricted_services}) : Octopussy::Service::List());
	foreach my $k (sort keys %service)
	{	
		foreach my $rs (@res_services)
		{
			if ($rs =~ /^$k$/)
			{
				push(@services, $k);
				last;
			}
		}
	}
	foreach my $s (sort @services)
	{ %> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $s %>","<%= $s %>"); <% 
	}
	$i++;
}

foreach my $d (sort @d_list) 
{
	my @res_services = (AAT::NOT_NULL($arg{restricted_services})
    ? AAT::ARRAY($arg{restricted_services}) : Octopussy::Service::List());
	my @services = ((AAT::NOT_NULL($d) && ($d ne "-ANY-"))
      	? sort(Octopussy::Device::Services($d)) : Octopussy::Service::List()); 
	my @list = ();
	foreach my $r (@res_services)
	{
		my $match = 0;
		foreach my $s (@services)
			{ $match = 1 if ($r =~ /^$s$/); }
		push(@list, $r)	if ($match);	
	}	
	my $i2 = 0;
	%>
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_any %>", "-ANY-");<%
 	if (defined $arg{unknown})
  { %> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_unknown %>", "Unknown");<%}
  foreach my $s (@list)
  {	%> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $s %>","<%= $s %>"); <% 
	}
  $i++;
}
%>

function update_service(x)
{
		var selected = 0;
		for (var i = 0; i < selector_device.options.length; i++)
		{
			if (selector_device.options[i].selected == 1)
				selected++;
		}
		if (selected > 1)
			x = 0; // full service list if more than one device selected
		for (var m = selector_service.options.length-1; m > 0; m--)
			selector_service.options[m] = null;
		for (var i = 0; i < service[x].length; i++)
			selector_service.options[i] = new Option(service[x][i].text, service[x][i].value);
}

update_service(selector_device.options.selectedIndex);

<%
my @selected_serv = keys %selected;
%>
var selected_serv = new Array(<%= $#selected_serv+1 %>);
<%
foreach my $s (AAT::ARRAY($arg{selected}))
{
%>selected_serv[i] = "<%= $s %>";<%
}
%>
for (i = 0; i < service[selector_device.options.selectedIndex].length; i++)
{
	for (j = 0; j < selected_serv.length; j++)
	{
		if (selector_service.options[i].value == selected_serv[j])
			selector_service.options[i].selected = true;
	}
}

var http_request_service = false;

function refresh_selector_service()
{
  var selector_device = document.forms[<%= $form_number %>].device;
  var devices_str = '';

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
    + "devices=" + devices_str, true);
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

      for (i = selector_service.options.length-1; i > 0; i--)
        selector_service.options[i] = null;
      for (i = 0; i < items.length; i++) 
      {
        var item = items[i].firstChild.data;
        selector_service.options[i+1] = new Option(item, item);
      }
    }
  } 
}

refresh_selector_service();
</script>
