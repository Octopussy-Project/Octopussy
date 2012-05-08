<% my %arg = @_; %>
<AAT:Box align="C" title="_TIMEPERIODS" icon="buttons/bt_period">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
  <AAT:BoxCol align="C"><AAT:Label value="_PERIODS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%
if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
  { %><AAT:Label value="_ACTION" style="B" /><% }
%></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $t (Octopussy::TimePeriod::Configurations($arg{sort}))
{
	my ($label, $periods) = ($t->{label}, $t->{periods});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
	%><AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$label" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$periods" /></i></AAT:BoxCol>
  <AAT:BoxCol align="C"><%
	if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
	{
%><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_timeperiod&arg1=$label&action=remove" /><%
	}
%></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
