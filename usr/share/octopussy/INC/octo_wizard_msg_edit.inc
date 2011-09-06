<%
my %arg = @_;
my $url = $arg{url};
my $service = $arg{service};
my $loglevel = $arg{loglevel};
my $taxonomy = $arg{taxonomy};
my $table = $arg{table};
my $msg_orig = $Server->HTMLEncode($arg{msg_orig});
my $msg_pattern = $arg{msg_pattern};
$msg_pattern =~ s/"/&quot;/g;
my ($m_begin, $m_end) = split (/:/, Octopussy::Service::Msg_ID($service));
my $colored_str = $Server->HTMLEncode(Octopussy::Message::Color($msg_pattern));
%>
<AAT:Box align="C">
<AAT:BoxRow>
<AAT:BoxCol cspan="2">
  <AAT:Box width="100%">
  <AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_SERVICE" style="B"/><%= ": $service" %></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_LOG_LEVEL" style="B"/><%= ": $loglevel" %></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_TAXONOMY" style="B"/><%= ": $taxonomy" %></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_TABLE" style="B"/><%= ": $table" %></AAT:BoxCol>
  </AAT:BoxRow>
  <AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
  <AAT:BoxRow>
  <AAT:BoxCol cspan="4"><div id="color_match"></div></AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol valign="top">
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
</AAT:BoxCol>
<script type="text/javascript">

function check_msgid(msgid)
{
  	service = document.form.service.value;

	$.get('ajax_check_msgid.asp?service=' + encodeURIComponent(service) + "&msgid="
    		+ encodeURIComponent(msgid.value), function(xml) { Print_Check_Result(xml); } );

	return true;
}

function check_pattern(pattern)
{
  	log = document.form.log.value;
  
	$.get('ajax_check_pattern.asp?pattern=' + encodeURIComponent(pattern.value) + "&log="
		+ encodeURIComponent(log), function(xml) { Print_Check_Result(xml); } );

	return true;
}

function Print_Check_Result(xml)
{
	var xmldoc = $.parseXML(xml);

	var msgid_status = $(xmldoc).find('msgid_status').text();
	if (msgid_status == "NOK")
      	{
        	img_status_msgid.innerHTML = "<img src=\"AAT/IMG/buttons/bt_msg_critical.png\" width=\"24\">";
      	}
      	else
      	{
        	img_status_msgid.innerHTML = "<img src=\"AAT/IMG/buttons/bt_msg_ok.png\" width=\"24\">";
      	}

      	var pattern_status = $(xmldoc).find('pattern_status').text();
      	if (pattern_status == "NOK")
      	{
		img_status_pattern.innerHTML = "<img src=\"AAT/IMG/buttons/bt_msg_critical.png\" width=\"24\">";
	}
	else
	{
		img_status_pattern.innerHTML = "<img src=\"AAT/IMG/buttons/bt_msg_ok.png\" width=\"24\">";
	}

      	if ((pattern_status == "OK") && (msgid_status == "OK")) 
		{ document.form.submit.disabled = false; }
	else
		{ document.form.submit.disabled = true; }

	var pattern_colored = document.getElementById("pattern_colored");
      	pattern_colored.innerHTML = $(xmldoc).find('pattern_colored').text();
	var color_match = document.getElementById("color_match");
      	color_match.innerHTML = $(xmldoc).find('color_match').text();
}
</script>
<AAT:BoxCol>
	<AAT:Form name="form" action="./wizard_msg_add.asp">
	<AAT:Form_Hidden name="log" value="$msg_orig" />
	<AAT:Form_Hidden name="msgid_begin" value="$m_begin" />
	<AAT:Form_Hidden name="service" value="$service" />
	<AAT:Form_Hidden name="loglevel" value="$loglevel" />
	<AAT:Form_Hidden name="taxonomy" value="$taxonomy" />
	<AAT:Form_Hidden name="table" value="$table" />
	<AAT:Box>
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_MSG_ID" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="$m_begin:" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="msgid_end" value="$m_end" size="80"
		onFocus="check_msgid(this)" onKeyUp="check_msgid(this)" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><div id="img_status_msgid"></div></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol cspan="3"><font size="-2">
  <div id="pattern_colored"></div>
	</font></AAT:BoxCol>
	<AAT:BoxCol align="R"><div id="img_status_pattern"></div></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  <AAT:BoxCol cspan="4">
	<AAT:TextArea name="msg_pattern" cols="100" rows="8" wrap="on" 
		data="$msg_pattern" onFocus="check_pattern(this)" 
		onKeyUp="check_pattern(this)" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="4">
	<AAT:Form_Submit name="submit" value="_FINISH" /></AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:Form>
</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
