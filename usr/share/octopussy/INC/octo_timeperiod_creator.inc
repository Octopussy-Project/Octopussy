<%
my %arg = @_;

my @weekdays = (
				{ label => undef, value => undef },
        { label => "_MONDAY", value => "Monday" },
        { label => "_TUESDAY", value => "Tuesday" },
        { label => "_WEDNESDAY", value => "Wednesday" },
        { label => "_THURSDAY", value => "Thursday" },
        { label => "_FRIDAY", value => "Friday" },
        { label => "_SATURDAY", value => "Saturday" },
        { label => "_SUNDAY", value => "Sunday" } );
%>
<AAT:Form action="$arg{action}">
<AAT:Box align="center">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_TIMEPERIOD_NAME" style="bold" /></AAT:BoxCol>
	<AAT:BoxCol cspan="4"><AAT:Entry name="name" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $i (1..7)
{
	my $label = $weekdays[$i]->{label};
  my $value = $weekdays[$i]->{value};
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$label" /></AAT:BoxCol>
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
	<AAT:BoxCol align="center" cspan="5">
	<AAT:Form_Submit value="_NEW_TIMEPERIOD" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
