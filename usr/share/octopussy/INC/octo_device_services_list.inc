<%
my %arg = @_;
my $url = $arg{url};
my $device = $arg{device};
$url .= "?device=$device";
my $url_sort = $url . "&device_services_table_sort";
my $sort = defined $arg{sort} ? lc($arg{sort}) : "rank";
my $role = $Session->{AAT_ROLE};
my @services = Octopussy::Device::Services($device);
my %stats = Octopussy::Device::Services_Statistics($device);
my $str = sprintf(AAT::Translation("_MSG_SERVICES_FOR_DEVICE"), $device);
my $dconf = Octopussy::Device::Configuration($device);

if (AAT::NOT_NULL($dconf->{reload_required}))
{
	%><AAT:Box align="C"><AAT:BoxRow>
	<AAT:BoxCol><AAT:Message level="1" msg="_RELOAD_REQUIRED" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Button name="reload" tooltip="_RELOAD" 
	link="./devices.asp?device=$device&action=parse_reload"/></AAT:BoxCol>
	</AAT:BoxRow></AAT:Box><%
}
%>
<AAT:Box align="C" title="$str" icon="buttons/bt_service">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_RANK" link="$url_sort=rank" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Label value="_SERVICE" link="$url_sort=sid" /></AAT:BoxCol>
  <AAT:BoxCol align="C"><AAT:Label value="_STATISTICS" /></AAT:BoxCol>
	<AAT:BoxCol align="C" cspan="5"><%
	if ($role !~ /ro/i)
  { 
    %><AAT:Label value="_ACTION" style="B" /><% 
  } 
  %></AAT:BoxCol>
  
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="8"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $nb_services = 0;
my $total_messages = 0;
foreach my $conf (Octopussy::Device::Services_Configurations($device, $sort))
{
	my $id = $conf->{sid};
  my $serv_conf = Octopussy::Service::Configuration($id);
  my $statistics_status = $conf->{statistics};
  my $s_str = ($statistics_status ? "Enabled" : "Disabled");
  my $s_action = ($statistics_status ? "disable" : "enable");
  my $nb_messages = scalar(@{$serv_conf->{message}}); 
	my $rank = $conf->{rank};
	my $serv_str = "$id " . (defined $stats{$id} ? "($stats{$id})" : "(0%)");
	my $dialog = "./dialog.asp?id=delete_device_service&arg1=$id&arg2=$device"; 
	my $class = (($nb_services%2) ? "boxcolor1" : "boxcolor2"); %>
<AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$rank" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="$serv_str" link="$url&service=$id&action=show" />
	</AAT:BoxCol>
  <%
	if ($role !~ /ro/i)
  {
    %><AAT:BoxCol align="C">
    <AAT:Label value="$s_str" link="$url&service=$id&action=$s_action"/>
    </AAT:BoxCol>
		<AAT:BoxCol align="R"><%
		if ($conf->{rank} > 2)
    {
	%><AAT:Button name="2uparrow" link="$url&service=$id&action=top" tooltip="Rank First" /><%
		}
		%></AAT:BoxCol><AAT:BoxCol align="R"><%
		if ($conf->{rank} > 1)
    { 
	%><AAT:Button name="1uparrow" link="$url&service=$id&action=up" tooltip="Rank -1" /><% 
		}
		%></AAT:BoxCol><AAT:BoxCol align="C"><%
		if ($conf->{rank} < scalar(@services))
    { 
	%><AAT:Button name="1downarrow" link="$url&service=$id&action=down" tooltip="Rank +1" /><% 
		}
		%></AAT:BoxCol><AAT:BoxCol align="C"><%
		if ($conf->{rank} < (scalar(@services)-1))
    {
  %><AAT:Button name="2downarrow" link="$url&service=$id&action=bottom" tooltip="Rank Last"/><%
    }
    %></AAT:BoxCol>
		<AAT:BoxCol>
		<AAT:Button name="remove" tooltip="_REMOVE" popup_link="$dialog" />
		</AAT:BoxCol><%
	} 
	else
		{ %><AAT:BoxCol cspan="6"></AAT:BoxCol><% } %>
</AAT:BoxRow><%
	$nb_services++;
  $total_messages += $nb_messages;
}
my $msg_str = "$nb_services " . AAT::Translation("_SERVICES") 
	. " / $total_messages " . AAT::Translation("_MESSAGES");
%>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="$msg_str" /></AAT:BoxCol>
	<AAT:BoxCol cspan="6"></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="8"><hr></AAT:BoxCol></AAT:BoxRow>
<%
if ($role !~ /ro/i)
{%>
<AAT:Form action="$url">
<AAT:Form_Hidden name="device" value="$device" />
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_service_and_servicegroup" exclude=\@services />
	</AAT:BoxCol>
	<AAT:BoxCol cspan="6" align="C">
	<AAT:Form_Submit value="_ADD_SERVICE_TO_DEVICE" />
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form><%
}
%>
</AAT:Box>
