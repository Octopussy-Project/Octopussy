<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "report_categories_table", url => $url, sort => $sort || "name",
	header_icon => "buttons/bt_report", header_title => "_REPORT_CATEGORIES",
	function => "Octopussy::Report::Categories",
	 fields => [
	 	{ name => "category", label => "_CATEGORY", 
			link_args => [ { name => "category", field_value=> "category" } ] },
		{ name => "nb", label => "_NB", alignment => "right" } ]	
	);

if ($Session->{AAT_ROLE} !~ /ro/i)
{
	my @items = ( { label => "_NEW_REPORT", link => "./report_creation.asp" } );
	%><AAT:Menu align="C" items=\@items /><%
}
%>
