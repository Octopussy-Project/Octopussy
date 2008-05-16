<%
my %arg = @_;
my @storages = ("DEFAULT", Octopussy::Storage::List());
my $dev_conf = Octopussy::Device::Configuration($arg{device});
my $d = Octopussy::Storage::Default();
my ($device_incoming, $device_unknown, $device_known) = 
	($dev_conf->{storage_incoming} || $d->{incoming}, 
	 $dev_conf->{storage_unknown} || $d->{unknown}, 
	 $dev_conf->{storage_known} || $d->{known});
my $title = sprintf(AAT::Translation("_MSG_STORAGES_FOR_DEVICE"), $arg{device});
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="C" title="$title" icon="buttons/bt_storage">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DIR_INCOMING_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $device_incoming ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="storage_incoming" selected="$device_incoming" 
		list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DIR_UNKNOWN_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $device_unknown ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="storage_unknown" selected="$device_unknown" 
		list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DIR_KNOWN_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $device_known ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="storage_known" selected="$device_known" 
		list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $s (Octopussy::Device::Services_Configurations($arg{device}, "rank"))
{
	my $service = $s->{sid};
	my $storage = $dev_conf->{"storage_$s->{sid}"} || $device_known;
%><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$service" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><%= "[ $storage ]" %></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Selector name="storage_$service" selected="$storage" list=\@storages />
  </AAT:BoxCol>
</AAT:BoxRow><%	
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="3">
  <AAT:Form_Hidden name="action" value="update" />
  <AAT:Form_Submit value="_MSG_UPDATE_CONFIG" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
