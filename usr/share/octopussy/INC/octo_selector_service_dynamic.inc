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
<select<%= $select_options %> name="service">
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
<script type="text/javascript">
var device = document.forms[<%= $form_number %>].device.options.length;
var service = new Array(device);
for (i = 0; i < device; i++)
	service[i] = new Array();
<%
my $i = 0;
my $i2 = 0;
%>
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_any %>", "-ANY-");
<%
if (defined $arg{unknown})
{ %> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $str_unknown %>", "Unknown"); 
<% }
my @services = (AAT::NOT_NULL($arg{restricted_services})
  ? AAT::ARRAY($arg{restricted_services}) : Octopussy::Service::List());
foreach my $s (@services)
{	%> 
service[<%=$i%>][<%=$i2++%>] = new Option("<%= $s %>","<%= $s %>"); 
<% }
$i++;

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
var temp = document.forms[<%= $form_number %>].service;


function update_service(x)
{
	var selected = 0;
	for (i = 0; i < document.forms[<%= $form_number %>].device.options.length; i++)
	{
		if (document.forms[<%= $form_number %>].device.options[i].selected == 1)
			selected++;
	}
	if (selected > 1)
		x = 0; // full service list if more than one device selected
	for (m = temp.options.length-1; m > 0; m--)
		temp.options[m] = null;
	for (i = 0; i < service[x].length; i++)
		temp.options[i] = new Option(service[x][i].text, service[x][i].value);
//	temp.options[0].selected = true;
}

update_service(document.forms[<%= $form_number %>].device.options.selectedIndex);
</script>
