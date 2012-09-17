<%
my $DEFAULT_LOGLEVEL = "Information";
my $DEFAULT_TABLE = "Message";
my $DEFAULT_TAXONOMY = "Application";
%>
<AAT:Box align="C">
<AAT:Form action="./wizard_msg_from_sample.asp">
<AAT:BoxRow>
    <AAT:BoxCol align="R">
	<AAT:Label value="_SERVICE" style="B" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Inc file="octo_selector_service" /></AAT:BoxCol>
    <AAT:BoxCol align="R"><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
  	<AAT:Inc file="octo_selector_table" selected="$DEFAULT_TABLE" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="R">
    <AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
    <AAT:Inc file="octo_selector_loglevel" selected="$DEFAULT_LOGLEVEL" />
    </AAT:BoxCol>
    <AAT:BoxCol align="R"><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
    <AAT:Inc file="octo_selector_taxonomy" selected="$DEFAULT_TAXONOMY" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_LOG" style="B" /></AAT:BoxCol>
  	<AAT:BoxCol cspan="3"><AAT:TextArea name="sample" cols="80" rows="5" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="4" align="C"><AAT:Form_Submit value="_SELECT_THIS_MSG" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
