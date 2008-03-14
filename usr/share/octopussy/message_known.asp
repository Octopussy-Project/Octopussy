<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<html>
<body>
<WebUI:Theme />
<div align="center">
<%
my %arg = @_;
my $logs = $arg{logs};
print $logs;

my $url = "./message_known.asp";
my @table = (
	[ { type => "form",
      args => { method => "post", action => $url } } ],
  [ { type => "AAT_TextArea",
      args => { name => "logs", cols => 120, rows => 20,
                wrap => "off", data => $Server->HTMLEncode($logs) } } ],
  [ { type => "AAT_Form_Submit", align => "center", 
      args => { name => "logs", value => "Submit" } },
    { type => "end_form" } ] );

$Response->Include('INC/box.inc', align => "center", elements => \@table);
%>
</div>
</body>
</html>
