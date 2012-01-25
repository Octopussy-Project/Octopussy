<%
my %arg = @_;

my $DEFAULT_LOGLEVEL = "Information";
my $DEFAULT_TABLE = "Message";
my $DEFAULT_TAXONOMY = "Application";

my $number = $arg{number};
my $device = $arg{device};
my $name = $arg{name};
my $orig = $arg{orig};
my $modified = $arg{modified};
my $nb = $arg{nb};
my $pattern = $modified;
$pattern =~ s/"/&quot;/g;
my $re = $arg{re};
my $url = "./wizard_msg.asp";
my $url_orig = $orig;
my $dialog = "./dialog.asp?id=delete_log";

my $lognumber = $1	if ($name =~ /#(\d+)/);
my $search_link = "./wizard_search_service.asp?device=$device&msg="
	. $Server->URLEncode($orig);

my $remove_link = "$dialog&device=$device&log=$lognumber&action=remove";

my $html_orig = $Server->HTMLEncode($orig);
my $modified_color = Octopussy::Message::Color_Without_Field($modified);
%>
<AAT:Form action="$url">
<AAT:Form_Hidden name="device" value="$device" />
<AAT:Form_Hidden name="msg_orig" value="$html_orig" />
<AAT:Form_Hidden name="msg_pattern" value="$pattern" />
<AAT:Box>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$name ($nb)" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_SERVICE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_service" device="$device" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_LOG_LEVEL" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_loglevel" selected="$DEFAULT_LOGLEVEL" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_TABLE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Inc file="octo_selector_table" selected="$DEFAULT_TABLE" /></AAT:BoxCol>
	<AAT:BoxCol width="100%"></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol>
	<AAT:Button name="remove" popup_link="$remove_link" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Button name="search" link="$search_link" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_ADD_NEW_SERVICE" 
		link="./device_services.asp?device=$device" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_TAXONOMY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_taxonomy" selected="$DEFAULT_TAXONOMY" /></AAT:BoxCol>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Form_Submit value="_SELECT_THIS_MSG" /></AAT:BoxCol>
	<AAT:BoxCol width="100%"></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="8"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Pattern: " style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="7"><AAT:Label value="$modified_color" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Sample: " style="B" /></AAT:BoxCol>
  <AAT:BoxCol cspan="7"><AAT:Label value="$html_orig" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
