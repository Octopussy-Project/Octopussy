<%
my %arg = @_;
my $tt = $arg{tooltip};
my $zabbix = AAT::Zabbix::Configuration($arg{appli});
my ($bin, $conf, $server, $host, $item) = 
	($zabbix->{bin}, $zabbix->{conf}, $zabbix->{zabbix_server}, 
		$zabbix->{zabbix_host}, $zabbix->{zabbix_item});
%>
<AAT:Box width="100%">
<AAT:Form method="POST" action="$arg{action}">
<AAT:Form_Hidden name="config" value="zabbix" />
<AAT:BoxRow>
  <AAT:BoxCol>
	<AAT:Label value="Zabbix" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_BINARY" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="zabbix_bin" value="$bin" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_CONFIG_FILE" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="zabbix_conf" value="$conf" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_ZABBIX_SERVER" style="B" tooltip="$tt" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="zabbix_server" value="$server" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_ZABBIX_HOST_DEFINED" style="B" tooltip="$tt" />
	</AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="zabbix_host" value="$host" size="50" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_ZABBIX_ITEM_DEFINED" style="B" tooltip="$tt" />
	</AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Entry name="zabbix_item" value="$item" size="50" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol><AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
