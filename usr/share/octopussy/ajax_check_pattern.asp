<%
use bytes;

my $pattern = $Request->QueryString("pattern");
my $log = $Request->QueryString("log");

my $regexp = Octopussy::Message::Pattern_To_Regexp({ pattern => $pattern });
my $pattern_status = ($log =~ /^$regexp\s*$/ ? "OK" : "NOK");
my $pattern_colored = $Server->HTMLEncode(Octopussy::Message::Color($pattern));
no bytes;
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<pattern_status><%= $pattern_status%></pattern_status>
	<pattern_colored><%= $pattern_colored %></pattern_colored>
</root>
