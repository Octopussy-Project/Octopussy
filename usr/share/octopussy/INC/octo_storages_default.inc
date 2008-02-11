<%
my %arg = @_;
my @storages = ("DEFAULT", Octopussy::Storage::List());
my $d = Octopussy::Storage::Default();
my ($d_incoming, $d_unknown, $d_known) = 
	($d->{incoming}, $d->{unknown}, $d->{known});
%>
<AAT:Form action="$arg{url}">
<AAT:Box align="center" title="_DEFAULT_STORAGES" icon="buttons/bt_storage">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DEFAULT_DIR_INCOMING_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $d_incoming ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="incoming" selected="$d_incoming" list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DEFAULT_DIR_UNKNOWN_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $d_unknown ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="unknown" selected="$d_unknown" list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_DEFAULT_DIR_KNOWN_LOGS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><%= "[ $d_known ]" %></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector name="known" selected="$d_known" list=\@storages />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="3">
	<AAT:Form_Hidden name="action" value="default" />
	<AAT:Form_Submit value="_MSG_UPDATE_CONFIG" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
