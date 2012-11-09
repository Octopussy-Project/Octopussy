<%
my %arg = @_;
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $role = $Session->{AAT_ROLE};
my $lnk = "${url}?devicegroups_table_sort";
%>
<AAT:Box align="C" title="_DEVICEGROUPS" icon="buttons/bt_devicegroup">
<AAT:BoxRow>
  	<AAT:BoxCol>
  	<AAT:Label value="_GROUP_NAME" link="$lnk=dg_id" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DESCRIPTION" link="$lnk=description" />
	</AAT:BoxCol>
  	<AAT:BoxCol>
  	<AAT:Label value="_TYPE" link="$lnk=type" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICES" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%
if ($role !~ /ro/i)
	{ %><AAT:Label value="_ACTION" style="B" /><% }
%></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $dg (Octopussy::DeviceGroup::Configurations($sort))
{
  my ($id, $desc, $type, $devices) = ($dg->{dg_id}, $dg->{description}, 
		$dg->{type}, ($dg->{device} ? join(", ", @{$dg->{device}}) : $dg->{device}));
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
	my $tooltip_str = "<b>Configuration:</b><br>";
	foreach my $crit (@{$dg->{criteria}})
	{
		$tooltip_str .= "Device " . ucfirst($crit->{field}) 
			. ": <i>$crit->{pattern}</i><br>";
	}
%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$id" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><i><AAT:Label value="$desc" no_trans="1" /></i></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$type" tooltip="$tooltip_str" /></AAT:BoxCol>
	<AAT:BoxCol><i><AAT:Label value="$devices" /></i></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
if ($role !~ /ro/i)
{
%><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_devicegroup&arg1=$id&action=remove" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
if ($role !~ /ro/i)
{
	my @device_fields = ( 
		{ label => "_DEVICE_NAME", value => "name" },
		{ label => "_DEVICE_ADDRESS", value => "address" },
		{ label => "_DEVICE_DESCRIPTION", value => "description" },
		{ label => "_DEVICE_TYPE", value => "type" },
    { label => "_DEVICE_MODEL", value => "model" },
		{ label => "_CITY", value => "city" },
		{ label => "_BUILDING", value => "building" },
		{ label => "_ROOM", value => "room" },
		{ label => "_RACK", value => "rack" } );
%>
<AAT:Form action="$url">
<AAT:Box align="C">
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GROUP_NAME" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>	
	<AAT:BoxCol><AAT:Label value="_DEVICES" style="B"/></AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="devicegroup" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="dg_description" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Inc file="selector_multi_device" name="devices" />
	</AAT:BoxCol>
	</AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="C" cspan="3">
	<AAT:Form_Submit value="_NEW_STATIC_DEVICEGROUP" /></AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<AAT:Form action="$url">
<AAT:Box align="C">
  <AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_GROUP_NAME" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B"/></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:Form_Hidden name="type" value="dynamic" />
	<AAT:BoxCol><AAT:Entry name="devicegroup" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="dg_description" size="40" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_FIELD" style="B"/></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_VALUE" style="B"/></AAT:BoxCol>
  </AAT:BoxRow>
<%
foreach my $i (1..3)
{
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Selector name="criteria_field$i" list=\@device_fields />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="criteria_value$i" size="40" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="C" cspan="2">
  <AAT:Form_Submit value="_NEW_DYNAMIC_DEVICEGROUP" /></AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
}
%>
