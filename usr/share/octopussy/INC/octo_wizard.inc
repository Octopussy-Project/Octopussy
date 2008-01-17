<%
my %arg = @_;

my $url = $arg{url};
my $url_sort = $url . "?wizard_table_sort=";
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
%>
<AAT:Box icon="buttons/bt_wizard" title="_LOGS_WIZARD" align="center">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_NAME" link= "${url_sort}name" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_IP_ADDRESS" link= "${url_sort}address" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DEVICE_TYPE" link= "${url_sort}type" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DEVICE_MODEL" link= "${url_sort}model" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DESCRIPTION" link= "${url_sort}description" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_UNKNOWN_MSGS" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $conf (Octopussy::Device::Configurations($sort))
{
	my $nb = Octopussy::Logs::Unknown_Number($conf->{name});
	my $name = $conf->{name};
	if ($nb > 0)
	{
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$name" link="$url?device=$name" /></AAT:BoxCol>
	<AAT:BoxCol><%= $conf->{address} %></AAT:BoxCol>
	<AAT:BoxCol><%= $conf->{type} %></AAT:BoxCol>
	<AAT:BoxCol><%= $conf->{model} %></AAT:BoxCol>
	<AAT:BoxCol><%= $conf->{description} %></AAT:BoxCol>
	<AAT:BoxCol align="right"><%= ($nb>20 ? "$nb+" : $nb) %></AAT:BoxCol>
	</AAT:BoxRow><%
	}
}
%>
</AAT:Box>
