<%
my %arg = @_;
my $service = $arg{service};
my $msgid = $arg{msgid};
my $conf = Octopussy::Message::Configuration($service, $msgid);
my ($m_begin, $m_end) = split (/:/, $conf->{msg_id});
my $loglevel = $conf->{loglevel};
my $taxo = $conf->{taxonomy};
my $table = $conf->{table};
my $rank = $conf->{rank};
my $pattern = $Server->HTMLEncode($conf->{pattern});
%>
<table>
<tr><td valign="top">
  <AAT:Box>
  <AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_FIELD" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_TYPE" style="B" /></AAT:BoxCol>
  </AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $f ((Octopussy::Table::Fields($table)))
{
  my ($title, $type) = ($f->{title}, $f->{type});
  %><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$title" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$type" style="B" /></AAT:BoxCol>
  </AAT:BoxRow><%
}%>
  </AAT:Box>

</td><td valign="top">

<AAT:Form action="$arg{action}">
<AAT:Form_Hidden name="service" value="$service" />
<AAT:Form_Hidden name="rank" value="$rank" />
<AAT:Form_Hidden name="old_msgid" value="$msgid" />
<AAT:Form_Hidden name="msgid_begin" value="$m_begin" />
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol cspan="2"><AAT:Label value="_MSG_ID" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
</AAT:BoxRow>	
<AAT:BoxRow>
	<AAT:BoxCol align="R"><AAT:Label value="$m_begin:" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="msgid_end" value="$m_end" size="30" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_loglevel" selected="$loglevel" />
	</AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_taxonomy" selected="$taxo" />
	</AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_table" selected="$table" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="5">
	<AAT:TextArea name="msg_pattern" cols="100" rows="8" 
		wrap="on" data="$pattern" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="5">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
</td>
</tr>
</table>
