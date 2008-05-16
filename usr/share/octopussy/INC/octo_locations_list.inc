<%
my %arg = @_;

my $url = $arg{url};
my $dialog = "./dialog.asp?id=delete_location_";
my $role = $Session->{AAT_ROLE};
%>
<AAT:Box icon="buttons/bt_home" title="_LOCATIONS" align="C">
	<AAT:Form action="$url">
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_CITY" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_BUILDING" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_ROOM" style="B"/></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Label value="_RACK" style="B"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_ACTION" style="B"/></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="city" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_NEW_CITY" /></AAT:BoxCol>
	<AAT:BoxCol cspan="4"></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
	</AAT:Form>
<%
foreach my $c (Octopussy::Location::Cities())
{
	my $dialog_city = $dialog . "city&arg1=$c";
	%><AAT:Form action="$url"><AAT:Form_Hidden name="city" value="$c" />
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$c" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="building" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Submit value="_NEW_BUILDING" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if ($role !~ /ro/)
		{ %><AAT:Button name="remove" popup_link="$dialog_city" /><% } %>
	</AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Form>
	<AAT:BoxRow><AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow><%
  foreach my $b (Octopussy::Location::Buildings($c))
  {
    my $dialog_building = $dialog . "building&arg1=$c&arg2=$b";
    %><AAT:Form action="$url"><AAT:Form_Hidden name="city" value="$c" />
    <AAT:Form_Hidden name="building" value="$b" />
    <AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="$c" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Label value="$b" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Entry name="room" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Form_Submit value="_NEW_ROOM" /></AAT:BoxCol>
    <AAT:BoxCol></AAT:BoxCol>
		<AAT:BoxCol align="C"><%
    if ($role !~ /ro/)
    	{ %><AAT:Button name="remove" popup_link="$dialog_building" /><% } %>
		</AAT:BoxCol>
    </AAT:BoxRow>
    </AAT:Form>
		<AAT:BoxRow><AAT:BoxCol cspan="2"></AAT:BoxCol>
		<AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow><%
    foreach my $r (Octopussy::Location::Rooms($c, $b))
    {
      my $dialog_room = $dialog . "room&arg1=$c&arg2=$b&arg3=$r";
      %><AAT:Form action="$url"><AAT:Form_Hidden name="city" value="$c" />
      <AAT:Form_Hidden name="building" value="$b" />
      <AAT:Form_Hidden name="room" value="$r" />
			<AAT:BoxRow>
			<AAT:BoxCol><AAT:Label value="$c" /></AAT:BoxCol>
    	<AAT:BoxCol><AAT:Label value="$b" /></AAT:BoxCol>
    	<AAT:BoxCol><AAT:Label value="$r" /></AAT:BoxCol>
      <AAT:BoxCol><AAT:Entry name="rack" /></AAT:BoxCol>
      <AAT:BoxCol><AAT:Form_Submit value="_NEW_RACK" /></AAT:BoxCol>
			<AAT:BoxCol align="C"><%
      if ($role !~ /ro/)
      	{ %><AAT:Button name="remove" popup_link="$dialog_room" /><% } %>
			</AAT:BoxCol>
      </AAT:BoxRow>
      </AAT:Form><%
			foreach my $rack (Octopussy::Location::Racks($c, $b, $r))
      {
        my $dialog_rack = $dialog . "rack&arg1=$c&arg2=$b&arg3=$r&arg4=$rack";
        %><AAT:BoxRow>
				<AAT:BoxCol><AAT:Label value="$c" /></AAT:BoxCol>
        <AAT:BoxCol><AAT:Label value="$b" /></AAT:BoxCol>
        <AAT:BoxCol><AAT:Label value="$r" /></AAT:BoxCol>
        <AAT:BoxCol><AAT:Label value="$rack" /></AAT:BoxCol>
        <AAT:BoxCol></AAT:BoxCol>
				<AAT:BoxCol align="C"><%
        if ($role !~ /ro/)
        	{ %><AAT:Button name="remove" popup_link="$dialog_rack" /><% } %>
				</AAT:BoxCol>
        </AAT:BoxRow>
        </AAT:Form><%			
			}
			%><AAT:BoxRow><AAT:BoxCol cspan="2"></AAT:BoxCol>
			<AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow><%
		}
		%><AAT:BoxRow><AAT:BoxCol></AAT:BoxCol>
		<AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow><%
	}
	%><AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow><%
}
%></AAT:Form>
</AAT:Box>
