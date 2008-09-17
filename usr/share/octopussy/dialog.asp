<%
my %button = 
	( info => "info", warning => "msg_warning", critical => "msg_critical" );
my $arg = $Request->QueryString();
my $d = Octopussy::Dialog($arg->{id});
my $bt = $button{$d->{type}};
my $msg = AAT::Translation($d->{msg});
my $link_ok = $d->{link_ok};
my $link_cancel = $d->{link_cancel};
$msg =~ s/\%\%(\S+)\%\%/$arg->{$1}/g;
$link_ok =~ s/\%\%([^\%]+)\%\%/$arg->{$1}/g;
$link_cancel =~ s/\%\%([^\%]+)\%\%/$arg->{$1}/g;
%>
<AAT:PageTop title="Octopussy Dialog" closepopup="Y" />
<AAT:Box align="C" cellpadding="0">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Button name="$bt" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Label value="$msg" size="+1" style="B" /></AAT:BoxCol>
	<AAT:BoxCol></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Box align="R" width="150">
	<AAT:BoxRow>
	<AAT:BoxCol align="R">
	<AAT:Button name="msg_ok" width="24" close_popup_link="$link_ok" />
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_OK" close_popup_link="$link_ok" />
	</AAT:BoxCol>
	</AAT:BoxRow>
	</AAT:Box>
	</AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Box width="150">
  <AAT:BoxRow>
	<AAT:BoxCol align="R">
	<AAT:Button name="msg_critical" width="24" close_popup_link="$link_cancel" />
	</AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_CANCEL" close_popup_link="$link_cancel" />
	</AAT:BoxCol>
	</AAT:BoxRow>
  </AAT:Box>
	</AAT:BoxCol>
	<AAT:BoxCol></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<AAT:PageBottom />
