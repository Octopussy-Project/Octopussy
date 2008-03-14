<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my $selecteds = $arg{selected};
my $selected = 0;
foreach my $s (AAT::ARRAY($selecteds))
	{ $selected = 1 if ($s eq "-ANY-"); }
my %dg_hash;
%>
<select<%= (defined $arg{multiple} ? " multiple" : "") %><%= (defined $arg{size} ? " size=$arg{size}" : "") %> name="device" 
	onchange="update_service(this.options.selectedIndex)">
<%
my @dgs = Octopussy::DeviceGroup::List();
my @dlist = (defined $arg{restricted_devices} 
	? AAT::ARRAY($arg{restricted_devices}) : Octopussy::Device::List());
my @devices = (defined $arg{list} ? AAT::ARRAY($arg{list}) : @dlist);

foreach my $dg (sort @dgs)
{
	my @dg_devices = Octopussy::DeviceGroup::Devices($dg);
	foreach my $d (@devices)
	{
		foreach my $dgd (@dg_devices)
		{
			if ($dgd =~ /^$d$/)
			{
				$dg_hash{$dg} = 1;
				last;
			}
		}
	}
}
$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "-ANY-",
    selected => ($selected ? "selected" : ""), 
		label => AAT::Translation("-ANY-"));
		
foreach my $dg (sort keys %dg_hash)
{
	my $selected = 0;
 	foreach my $s (AAT::ARRAY($selecteds))
 		{ $selected = 1 if ($s eq "group $dg"); }
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "group $dg",
		selected => ($selected ? "selected" : ""), label => "< $dg >");
}
foreach my $d (@devices)
{
	my $selected = 0;
  foreach my $s (AAT::ARRAY($selecteds))
    { $selected = 1 if ($s eq $d); }
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $d,
    selected => ($selected ? "selected" : ""), label => $d);
}
%>
</select>
