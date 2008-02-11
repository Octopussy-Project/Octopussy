<%
#use encoding 'utf8';

my %arg = @_;
my $msg_orig = $Server->HTMLEncode($arg{msg_orig});
my $msg_pattern = Octopussy::Message::Color_Without_Field($arg{msg_pattern});
%>
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_SERVICE" style="B" />
	: <AAT:Label value="$arg{service}" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_LOG_LEVEL" style="B" />
  : <AAT:Label value="$arg{loglevel}" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TAXONOMY" style="B" />
  : <AAT:Label value="$arg{taxonomy}" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TABLE" style="B" />
  : <AAT:Label value="$arg{table}" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="4"><AAT:Label value="$msg_orig" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="4"><AAT:Label value="$msg_pattern" /></AAT:BoxCol> 
</AAT:BoxRow>
</AAT:Box>
