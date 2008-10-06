<%
my %arg = @_;
my $url = $arg{url};
my @tables_confs = Octopussy::Table::Configurations();
my $tables_update = Octopussy::Web_Updates("Tables");
%>
<AAT:Box icon="buttons/bt_table" title="_TABLES_UPDATES" align="C">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_TABLE_NAME" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_VERSION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
  <AAT:Form action="$url">
<%
my $has_updates = 0;
foreach my $tc (@tables_confs)
{
  if ($tables_update->{$tc->{name}} > $tc->{version})
  {
		my ($tc_name, $tc_desc, $diff_version) = ($tc->{name}, $tc->{description},
      "$tables_update->{$tc->{name}} > $tc->{version}");
    $has_updates = 1;
	%><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$tc_name" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$tc_desc" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$diff_version" /></AAT:BoxCol>
  <AAT:BoxCol align="C"><AAT:Label value="_SHOW_DIFF" 
		link_new="./updater_diff.asp?table=$tc_name"/></AAT:BoxCol>
  <AAT:BoxCol align="C">
  <AAT:CheckBox name="table_update_$tc_name" /></AAT:BoxCol>
  </AAT:BoxRow><%
  }
}
foreach my $k (sort keys %{$tables_update})
{
	my $match = 0;
	foreach my $tc (@tables_confs)
		{ $match = 1	if ($tc->{name} eq $k); }
	if (!$match)
	{
		$has_updates = 1;
		%><AAT:BoxRow><AAT:BoxCol cspan="2"><AAT:Label value="$k" /></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:Label value="_NEW_TABLE" color="red"/></AAT:BoxCol>
    <AAT:BoxCol align="C">
    <AAT:CheckBox name="stable_update_$k" selected="1"/></AAT:BoxCol>
    </AAT:BoxRow><%
	}
}
if ($has_updates)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol align="C" cspan="5">
  <AAT:Form_Submit value="_MSG_UPDATE_SELECTED_TABLES" />
  </AAT:BoxCol></AAT:BoxRow><%
}
else
{
	%><AAT:BoxRow><AAT:BoxCol align="C" cspan="5">
  <AAT:Label value="_MSG_NO_UPDATES_AVAILABLE" style="B"/>
	</AAT:BoxCol></AAT:BoxRow><%
}
%></AAT:Form>
</AAT:Box>
