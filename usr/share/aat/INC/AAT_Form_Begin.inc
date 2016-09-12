<% my %arg = @_; %>
<form name="<%= ($arg{name} || "unknown") %>" method="<%= ($arg{method} || "POST") %>" action="<%= $arg{action} %>">
<% 
if ((!defined $arg{method}) || ($arg{method} eq "") || ($arg{method} =~ /^POST$/i))
{
	use Data::GUID;

	my $guid = Data::GUID->new;
	my $token = $guid->as_string;
	$Session->{CSRFtoken} = $token;	
%>
	<AAT:Form_Hidden name="CSRFtoken" value="$token" />
<%
}
%>
