<%
my %arg = @_;
my $tt = $arg{tooltip};
my $nsca = AAT::NSCA::Configuration($arg{appli});
my ($bin, $conf, $server, $host, $service) = 
	($nsca->{bin}, $nsca->{conf}, $nsca->{nagios_server}, 
		$nsca->{nagios_host}, $nsca->{nagios_service});
%>
<AAT:Box width="100%">
<AAT:Form method="POST" action="$arg{action}">
<AAT:Form_Hidden name="config" value="nsca" />
<AAT:BoxRow>
  <AAT:BoxCol>
	<AAT:Label value="NSCA(Nagios)" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_BINARY" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="nsca_bin" value="$bin" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_CONFIG_FILE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="nsca_conf" value="$conf" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_NAGIOS_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="nsca_nagios_server" value="$server" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_NAGIOS_HOST_DEFINED" style="B" tooltip="$tt" />
	</AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="nsca_nagios_host" value="$host" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_NAGIOS_SERVICE_DEFINED" style="B" tooltip="$tt" />
	</AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="nsca_nagios_service" value="$service" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
