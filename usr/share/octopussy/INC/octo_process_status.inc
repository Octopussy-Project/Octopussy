<AAT:Box align="C">
<%
my %proc = Octopussy::Process_Status();
foreach my $k (sort keys %proc)
{
	my $status = ($proc{$k} != 0 ? "_STARTED" : "_STOPPED");
  my $color = ($proc{$k} != 0 ? "green" : "red");
%><AAT:BoxRow>
		<AAT:BoxCol align="C">
			<AAT:Label value="$k" style="B" color="$color" />
			<AAT:Label value="$status" style="B" color="$color" />	
		</AAT:BoxCol>
	</AAT:BoxRow><%
}
if ($Session->{AAT_ROLE} =~ /admin/i)
{
%>
  <AAT:BoxRow><AAT:BoxCol><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol align="C">
			<AAT:Label value="_MSG_RESTART_OCTOPUSSY" style="B" 
				link="./index.asp?action=restart" />
		</AAT:BoxCol>
	</AAT:BoxRow><% 
}
%>
</AAT:Box>
