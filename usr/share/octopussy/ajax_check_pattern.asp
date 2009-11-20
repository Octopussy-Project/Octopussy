<%
use bytes;

my $pattern = $Request->QueryString("pattern");
my $log = $Request->QueryString("log");

my $regexp = Octopussy::Message::Pattern_To_Regexp({ pattern => $pattern });
my $pattern_status = ($log =~ /^$regexp\s*$/ ? "OK" : "NOK");
my $pattern_colored = $Server->HTMLEncode(Octopussy::Message::Color($pattern));

my ($match, $unmatch) = Octopussy::Message::Color_Match($log, $regexp);
my $color_match = $Server->HTMLEncode(qq($match<font style="background-color: red">$unmatch</font>));
no bytes;
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
  <color_match><%= $color_match %></color_match>
	<pattern_status><%= $pattern_status %></pattern_status>
	<pattern_colored><%= $pattern_colored %></pattern_colored>
</root>
