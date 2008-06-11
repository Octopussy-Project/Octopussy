<WebUI:PageTop title="Wizard Search Service" />
<%
my $device = $Request->QueryString("device");
my $msg = $Request->QueryString("msg");
my $url = "./device_services.asp?device=$device";
my $match = 0;
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"><AAT:Label value="$msg" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $serv (Octopussy::Service::List())
{
    my @msg_to_parse = ();
    my @messages = Octopussy::Service::Messages($serv);
    foreach my $m (@messages)
    {
      my $regexp = Octopussy::Message::Pattern_To_Regexp($m);
			if ($msg =~ /^$regexp\s*[^\t\n\r\f -~]?$/i)
			{
				$match = 1;
				%><AAT:BoxRow><AAT:BoxCol>
				<AAT:Label value="Matches Service " /><b><%= $serv %></b></AAT:BoxCol>
				<AAT:BoxCol align="R">
				<AAT:Button name="add" link="${url}&service=$serv" /></AAT:BoxCol>
				</AAT:BoxRow><%
			}
    }
}
if (!$match)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="2" align="C">
	<AAT:Label value="No Matching Service !" link="./wizard.asp?device=$device" />
	</AAT:BoxCol></AAT:BoxRow><%
}
%>
</AAT:Box>
