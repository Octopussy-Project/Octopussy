<%
my %arg = @_;
my $url = $arg{url};
my $device = $arg{device};
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
<AAT:BoxCol>
    <AAT:Form name="form" action="./wizard_msg_add.asp">
	<AAT:Form_Hidden name="device" value="$device" />	
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
    <AAT:Entry id="msgid_end" name="msgid_end" value="$m_end" size="80"
        onFocus="Check_MsgID()" onKeyUp="Check_MsgID()" /></AAT:BoxCol>
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
    <AAT:TextArea id="msg_pattern" name="msg_pattern" cols="100" rows="8" wrap="on" 
        data="$msg_pattern" onFocus="Check_Pattern()"  
        onKeyUp="Check_Pattern()" /></AAT:BoxCol>
    </AAT:BoxRow>
    <AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
    <AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="4">
    <AAT:Form_Submit id="submit_back_to_wizard" name="submit_back_to_wizard" value="_SAVE_MSG_GO_BACK_TO_WIZARD" />
    <AAT:Form_Submit id="submit_go_to_service" name="submit_go_to_service" value="_SAVE_MSG_GO_TO_SERVICE" />
	</AAT:BoxCol>
    </AAT:BoxRow>
    </AAT:Box>
    </AAT:Form>
</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<script type="text/javascript">

function Check_MsgID()
{
    $.get('ajax_check_msgid.asp?service=' + encodeURIComponent($('input[name=service]').val()) + '&msgid='
        + encodeURIComponent($('#msgid_end').val()), function(xml) { 
            var xmldoc = $.parseXML(xml); 
            var msgid_status = $(xmldoc).find('msgid_status').text();
            if (msgid_status == 'NOK')
            {
                $('#img_status_msgid').html('<img src="AAT/IMG/buttons/bt_msg_critical.png" width="24">');
                $('input[type="submit"]').attr('disabled', 'disabled');
            }
            else
            {
                $('#img_status_msgid').html('<img src="AAT/IMG/buttons/bt_msg_ok.png" width="24">');
                if ($('#img_status_pattern').html() == '<img src="AAT/IMG/buttons/bt_msg_ok.png" width="24">')
                    { $('input[type="submit"]').removeAttr('disabled'); }
            }
            } );
}

function Check_Pattern()
{
    $.get('ajax_check_pattern.asp?pattern=' + encodeURIComponent($('#msg_pattern').val()) + '&log='
        + encodeURIComponent($('input[name=log]').val()), function(xml) {
            var xmldoc = $.parseXML(xml);
            var pattern_status = $(xmldoc).find('pattern_status').text();
            if (pattern_status == 'NOK')
            {
                $('#img_status_pattern').html('<img src="AAT/IMG/buttons/bt_msg_critical.png" width="24">');
                $('input[type="submit"]').attr('disabled', 'disabled');
            }
            else
            {
                $('#img_status_pattern').html('<img src="AAT/IMG/buttons/bt_msg_ok.png" width="24">');
                if ($('#img_status_msgid').html() == '<img src="AAT/IMG/buttons/bt_msg_ok.png" width="24">')
                    { $('input[type="submit"]').removeAttr('disabled'); }
            }
            var pattern_colored = document.getElementById("pattern_colored");
            pattern_colored.innerHTML = $(xmldoc).find('pattern_colored').text();
            var color_match = document.getElementById("color_match");
            color_match.innerHTML = $(xmldoc).find('color_match').text();
        } );
}

$(document).ready(function() {
Check_MsgID();
Check_Pattern();
});

</script>
