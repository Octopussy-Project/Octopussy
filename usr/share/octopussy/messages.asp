<WebUI:PageTop title="_MESSAGES" help="#messages_page" />
<%
my $service = $Session->{service};
my $loglevel = $Session->{loglevel};
my $taxo = $Session->{taxonomy};
my $table = $Session->{table};
my $sort = $Session->{sort};
%>
<AAT:Inc file="octo_messages_filter_box" url="./messages.asp"
	service="$service" loglevel="$loglevel" taxonomy="$taxo" table="$table" />
<AAT:Inc file="octo_messages_list" url="./messages.asp" sort="$sort" 
	service="$service" loglevel="$loglevel" taxonomy="$taxo" table="$table" />
<WebUI:PageBottom />
