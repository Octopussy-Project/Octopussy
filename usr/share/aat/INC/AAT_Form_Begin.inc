<% my %arg = @_; %>
<form name="<%= ($arg{name} || "unknown") %>" method="<%= ($arg{method} || "POST") %>" action="<%= $arg{action} %>">
<% 
if ((!defined $arg{method}) || ($arg{method} eq "") || ($arg{method} =~ /^POST$/i))
{
	my $token = undef;

	if (defined $Session->{CSRFtoken})
	{	# not the first form on the page
		$token = $Session->{CSRFtoken};
	}
	else
	{
		use Data::GUID;

		my $guid = Data::GUID->new;
		$token = $guid->as_string;
		$Session->{CSRFtoken} = $token;	
	}
%>
	<AAT:Form_Hidden name="CSRFtoken" value="$token" />
<%
}
%>
