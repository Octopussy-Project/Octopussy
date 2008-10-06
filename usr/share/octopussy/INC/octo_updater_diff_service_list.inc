<% my %arg = @_; %>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_MODIFICATION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_RANK" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_MSG_ID" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $m (Octopussy::Service::Updates_Diff($arg{service}))
{
  my $msg_color = Octopussy::Message::Color($m->{pattern});
	my $status = $m->{status} || "modified";
	my ($rank, $msgid, $loglevel, $taxonomy, $table) = 
		($m->{rank}, $m->{msg_id}, $m->{loglevel}, $m->{taxonomy}, $m->{table});
	%><AAT:BoxRow>
	<AAT:BoxCol rspan="2"><AAT:Label value="$status" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$rank" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$msgid" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$loglevel" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$taxonomy" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$table" style="B" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol cspan="5"><AAT:Label value="$msg_color" size="-2" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow><%
}
%>
</AAT:Box>
