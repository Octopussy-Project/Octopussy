<%
my $cpu = Octopussy::Stats::CPU_Usage();
my $cpu_str = "User: $cpu->{user}% System: $cpu->{system}% "
	. "Idle: $cpu->{idle}% Wait: $cpu->{wait}%";
my @storages = Octopussy::Stats::Partition_Logs();
my $nb_storages = scalar(@storages) + 1;
%>
<AAT:Box align="C">
  <AAT:BoxRow>
		<AAT:BoxCol rspan="2"><AAT:IMG name="hardware_cpu" /></AAT:BoxCol>
    <AAT:BoxCol valign="top">
		<AAT:Label value="_PROCESSOR" style="B" /></AAT:BoxCol>
		<AAT:BoxCol valign="top" cspan="2">
		<AAT:Label value=&Octopussy::Stats::CPU_Info() /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol valign="top">
		<AAT:Label value="_CPU_USAGE" style="B" /></AAT:BoxCol>
    <AAT:BoxCol valign="top" cspan="2">
		<AAT:Label value="$cpu_str" /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol rspan="3"><AAT:IMG name="hardware_memory" /></AAT:BoxCol>
    <AAT:BoxCol valign="top">
		<AAT:Label value="_MEM_USAGE" style="B" /></AAT:BoxCol>
    <AAT:BoxCol valign="top" cspan="2">
		<AAT:Label value=&Octopussy::Stats::Mem_Usage() /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol valign="top">
		<AAT:Label value="_SWAP_USAGE" style="B" /></AAT:BoxCol>
    <AAT:BoxCol valign="top" cspan="2">
		<AAT:Label value=&Octopussy::Stats::Swap_Usage() /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol valign="top">
		<AAT:Label value="_LOAD" style="B" /></AAT:BoxCol>
    <AAT:BoxCol valign="top" cspan="2">
		<AAT:Label value=&Octopussy::Stats::Load() /></AAT:BoxCol>  
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol rspan="$nb_storages">
		<AAT:IMG name="generic_used_space" /></AAT:BoxCol>
		<AAT:BoxCol rspan="$nb_storages">
		<AAT:Label value="_STORAGES" style="B" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
		<AAT:BoxCol align="R">
		<AAT:Label value="_USED_SPACE" style="B" /></AAT:BoxCol>
	</AAT:BoxRow>
<%
foreach my $s (@storages)
{
	my ($name, $used) = ($s->{directory}, $s->{usage});
%><AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="$name" /></AAT:BoxCol>
		<AAT:BoxCol align="R"><AAT:Label value="$used" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
