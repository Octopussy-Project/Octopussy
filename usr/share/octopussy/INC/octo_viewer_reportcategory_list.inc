<%
my %arg = @_;

my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";

my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN});
my @res_reports = AAT::ARRAY($restricts->{report});
 
$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "report_categories_table", url => $url, sort => $sort || "name",
	header_icon => "buttons/bt_report", header_title => "_REPORTS_VIEWER",
	function => "Octopussy::Report::Categories",
	function_args => \@res_reports,
	 fields => [
	 	{ name => "category", label => "_CATEGORY", 
			link_args => [ { name => "category", field_value=> "category" } ] },
		{ name => "nb", label => "_NB", alignment => "right" } ]	
	);
%>
