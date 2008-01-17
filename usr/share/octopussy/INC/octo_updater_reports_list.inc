<%
my %arg = @_;
my $url = $arg{url};
my @reports_confs = Octopussy::Report::Configurations(undef, undef);
my $reports_update = Octopussy::Web_Updates("Reports");
%>
<AAT:Box icon="buttons/bt_report" title="_REPORTS_UPDATES" align="C">
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_REPORT_NAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_VERSION" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:Form action="$url">
<%
my $has_updates = 0;
foreach my $rc (@reports_confs)
{
  if ($reports_update->{$rc->{name}} > $rc->{version})
  {
		my ($rc_name, $rc_desc, $diff_version) = ($rc->{name}, $rc->{description}, 
			"$reports_update->{$rc->{name}} > $rc->{version}");
    $has_updates = 1;
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$rc_name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$rc_desc" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$diff_version" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:CheckBox name="report_update_$rc_name" /></AAT:BoxCol>
	</AAT:BoxRow><%
  }
}
foreach my $k (sort keys %{$reports_update})
{
	my $match = 0;
	foreach my $rc (@reports_confs)
		{ $match = 1	if ($rc->{name} eq $k); }
	if (!$match)
	{
		$has_updates = 1;
		%><AAT:BoxRow><AAT:BoxCol cspan="2"><AAT:Label value="$k" /></AAT:BoxCol>
		<AAT:BoxCol align="C">
		<AAT:Label value="_NEW_REPORT" color="red"/></AAT:BoxCol>
		<AAT:BoxCol align="C">
  	<AAT:CheckBox name="report_update_$k" /></AAT:BoxCol>
		</AAT:BoxRow><%
	}
}
if ($has_updates)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol align="C", cspan="4">
	<AAT:Form_Submit value="_MSG_UPDATE_SELECTED_REPORTS" />
	</AAT:BoxCol></AAT:BoxRow><%
}
else
{
	%><AAT:BoxRow><AAT:BoxCol align="C" cspan="4">
	<AAT:Label value="_MSG_NO_UPDATES_AVAILABLE" style="B"/>
	</AAT:BoxCol></AAT:BoxRow><%
}
%></AAT:Form>
</AAT:Box>
