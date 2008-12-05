<WebUI:PageTop title="_REPORT_CREATION" />
<%
my $f = $Request->Form();
my @select = $f->{select};

if (AAT::NULL($f->{title}))
{
	%><AAT:Inc file="octo_report_data_configurator" url="./report_creation.asp" /><%
}
elsif ($select[0] eq "")
{
	%><AAT:Inc file="octo_report_query_configurator" url="./report_creation.asp"
			title="$f->{title}" description="$f->{description}"
			graph_type="$f->{graph_type}" table="$f->{table}" /><%
}
else
{
	my $query = "SELECT ";
	$query .= join(", ", @select);
	$query .= " FROM $table" . ($f->{where} ne "" ? "WHERE $f->{where}" : "")
		. ($f->{group_by} ne "" ? " GROUP BY $f->{group_by}" : "")
		. ($f->{order_by} ne "" ? " ORDER BY $f->{order_by}" : "");
	Octopussy::Report::New(
		{ name => $f->{title}, description => $f->{description},
			graph_type => $f->{graph_type}, table => $f->{table}, query => $query })
		if ($Session->{AAT_ROLE} !~ /ro/i);
}
%>
<WebUI:PageBottom />
