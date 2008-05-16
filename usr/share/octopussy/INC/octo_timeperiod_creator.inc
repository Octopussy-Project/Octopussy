<% my %arg = @_; %>
<AAT:Form action="$arg{action}">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_TIMEPERIOD_NAME" style="bold" /></AAT:BoxCol>
	<AAT:BoxCol cspan="4"><AAT:Entry name="name" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $i (1..7)
{
	my $day = AAT::Datetime::WeekDay_Name($i);
  my $value = AAT::Translation::Get("EN", $day);
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$day" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_Time name="${value}_start" step="5" selected="0/0"/>
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Selector_Time name="${value}_finish" step="5" selected="0/0"/>
  </AAT:BoxCol>
	<AAT:BoxCol><AAT:CheckBox name="${value}_Negate" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_NEGATE" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="5">
	<AAT:Form_Submit value="_NEW_TIMEPERIOD" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
