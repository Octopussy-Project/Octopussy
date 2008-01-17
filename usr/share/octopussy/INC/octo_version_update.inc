<% my $version = "Octopussy v" . Octopussy::Version(); %>
<AAT:Box align="center">
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="$version" size="+1" style="B" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R">
	<AAT:Button name="web" link="./updater.asp" />
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_MSG_CHECK_UPDATES" link="./updater.asp" />
	</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
