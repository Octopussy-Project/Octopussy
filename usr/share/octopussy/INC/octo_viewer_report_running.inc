<%
use Date::Manip;

my @list = Octopussy::Report::Running_List();
if (scalar(@list) > 0)
{
%><AAT:Box align="C" icon="buttons/bt_report" title="_RUNNING_REPORTS">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_REPORT" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_DEVICES" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_STARTED" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_STATUS" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
	foreach my $i (@list)
	{
		my $status = "$1 " . int($2/$3*100) . "%"
			if ($i->{status} =~ /^(.+) \[(\d+)\/(\d+)\]/);
	%><AAT:BoxRow>
	<AAT:BoxCol><b><%= $i->{report} %></b></AAT:BoxCol>
	<AAT:BoxCol><i><%= $i->{devices} %></i></AAT:BoxCol>
	<AAT:BoxCol><i><%= $i->{services} %></i></AAT:BoxCol>
	<AAT:BoxCol><i><%= $i->{started} %></i></AAT:BoxCol>
	<AAT:BoxCol><b><%= $status %></b></AAT:BoxCol>
 	</AAT:BoxRow><%
	}	
%></AAT:Box><%
}
%>
