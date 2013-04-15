<%
use bytes;

my $pattern = $Request->QueryString("pattern");
my $log = $Request->QueryString("log");

my $regexp = Octopussy::Message::Pattern_To_Regexp({ pattern => $pattern });
my $pattern_status = ($log =~ /^$regexp\s*$/ ? "OK" : "NOK");
my $pattern_colored = Octopussy::Message::Color($pattern);

my ($match, $unmatch) = Octopussy::Message::Minimal_Match($log, $regexp);

my $color_match = 
	$Server->HTMLEncode($match) . qq(<font style="background-color: red">) . $Server->HTMLEncode($unmatch) . qq(</font>); 
#. qq(<font style="background-color: red">) 
#	. $unmatch; 
#. qq(</font>);

no bytes;

if (NOT_NULL($Session->{AAT_LOGIN}))
{
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
  <color_match><![CDATA[<%= $color_match %>]]></color_match>
	<pattern_status><%= $pattern_status %></pattern_status>
	<pattern_colored><![CDATA[<%= $pattern_colored %>]]></pattern_colored>
</root>
<%
}
%>
