<% 
my %arg = @_; 
my $selecteds = $arg{selected};
my $selected = 0;
foreach my $s (AAT::ARRAY($selecteds))
  { $selected = 1 if ($s eq "-ANY-"); }
my %service;
my @services = ();
my $arg_devices = $arg{device};
foreach my $d (AAT::ARRAY($arg_devices))
{
	if ($d =~ /^group (.+)/)
	{
		foreach my $s (Octopussy::DeviceGroup::Services($1))
			{ $service{$s} = 1; }
	}
	else
	{
		my @serv = ((defined $d && $d ne "" && $d ne "-ANY-") 
			? sort(Octopussy::Device::Services($d)) : Octopussy::Service::List());
		foreach my $s (@serv)
			{ $service{$s} = 1; }
	}
}
foreach my $k (sort keys %service)
	{ push(@services, $k); }

@services = (defined $arg{restricted_services} 
	? AAT::ARRAY($arg{restricted_services}) : @services);
@services = AAT::ARRAY($arg{list})	if (defined $arg{list});
%>
<select<%= (defined $arg{multiple} ? " multiple" : "") %><%= (defined $arg{size} ? " size=$arg{size}" : "") %> name="service">
<% 
if ($#services > -1)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "-ANY-",
		selected => ($selected ? "selected" : ""), 
		label => AAT::Translation("-ANY-"));
}

$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "Unknown",
    selected => ($selected ? "selected" : ""),
    label => AAT::Translation("<Unknown>"));

foreach my $s (@services)
{
	my $selected = 0;
	my @selection = AAT::ARRAY($selecteds);
	foreach my $sel (@selection)
  	{ $selected = 1	if ($sel eq $s); }
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $s,
    selected => ($selected ? "selected" : ""), label => $s);
}
%>
</select>
<script type="text/javascript">
var device=document.forms[0].device.options.length;
var service=new Array(device);
for (i=0; i<device; i++)
	service[i]=new Array();
<%
my $i = 0;
my $i2 = 0;

my @services = (AAT::Translation("-ANY-"), Octopussy::Service::List());
foreach my $s (@services)
{%>
service[<%= $i %>][<%= $i2 %>]=new Option("<%= $s %>","<%= $s %>");<%
	$i2++;
}
$i++;

my @dgs = Octopussy::DeviceGroup::List();
foreach my $d (sort @dgs)
{
	my @dg_devices = Octopussy::DeviceGroup::Devices($d);
	if ($#dg_devices >= 0)
	{
		my @services = (AAT::Translation("-ANY-"), 
			Octopussy::DeviceGroup::Services($d));
		my $i2 = 0;
		foreach my $s (@services)
		{%>
service[<%= $i %>][<%= $i2 %>]=new Option("<%= $s %>","<%= $s %>");<%
			$i2++;
		}
		$i++;
	}
}
foreach my $d (Octopussy::Device::List())
{
	my @services = (AAT::Translation("-ANY-")
		, ((defined $d && $d ne "" && $d ne "-ANY-")
      	? sort(Octopussy::Device::Services($d)) : Octopussy::Service::List())); 
	my $i2 = 0;
  foreach my $s (@services)
  {%>
service[<%= $i %>][<%= $i2 %>]=new Option("<%= $s %>","<%= $s %>");<%
  $i2++;
  }
  $i++;
}
%>
var temp=document.forms[0].service;

function update_service(x)
{
	for (m=temp.options.length-1; m>0; m--)
		temp.options[m]=null;
	for (i=0; i<service[x].length; i++)
		temp.options[i]=new Option(service[x][i].text,service[x][i].value);
	temp.options[0].selected=true;
}
</script>
