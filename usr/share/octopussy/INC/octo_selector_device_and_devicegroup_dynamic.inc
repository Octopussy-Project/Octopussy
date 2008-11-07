<% 
my %arg = @_; 
my $select_options = (defined $arg{multiple} ? " multiple" : "") 
	. (defined $arg{size} ? " size=$arg{size}" : "");

my %selected = ();
foreach my $s (AAT::ARRAY($arg{selected}))
  { $selected{$s} = 1; }

my @restricted_devices = (AAT::NOT_NULL($arg{restricted_devices})
	? AAT::ARRAY($arg{restricted_devices}) : ());
my (@dg_list, @d_list) = ((), ());

if (AAT::NOT_NULL(\@restricted_devices))
{
	foreach my $e (@restricted_devices)
		{ push(@dg_list, $1) if ($e =~ /^group (.+)$/); }
}
else
	{ @dg_list = Octopussy::DeviceGroup::List(); }

if (AAT::NOT_NULL(\@restricted_devices))
{
	foreach my $e (@restricted_devices)
    { push(@d_list, $e) if ($e !~ /^group /); }
}
else
	{ @d_list = Octopussy::Device::List(); }
%>
<select<%= $select_options %> name="device"
  onchange="refresh_selector_service();refresh_selector_taxonomy()">
<%
$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "-ANY-",
	selected => ($selected{"-ANY-"} ? "selected" : ""), 
	label => AAT::Translation("-ANY-"));
foreach my $dg (sort @dg_list)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "group $dg",
		selected => ($selected{"group $dg"} ? "selected" : ""), label => "< $dg >");
}
foreach my $d (sort @d_list)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $d,
  	selected => ($selected{$d} ? "selected" : ""), label => $d);
}
%>
</select>
