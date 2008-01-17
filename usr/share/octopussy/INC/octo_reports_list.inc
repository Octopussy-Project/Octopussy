<%
my %arg = @_;

my $url = $arg{url};
my $category = $arg{category};
my $sort = (defined $arg{sort} ? lc($arg{sort}) : "name");
my $role = $Session->{AAT_ROLE};

$Response->Include("AAT/INC/AAT_Table_Function.inc",
  id => "reports_table", url => $url, sort => $sort || "name",
  header_icon => "buttons/bt_report", header_title => "_REPORTS",
  function => "Octopussy::Report::Configurations",
  function_args => [ $sort, $category ],
  fields => [
    { name => "name", label => "_NAME",
      link_args => [ { name => "report", field_value=> "name" } ] },
    { name => "description", label => "_DESCRIPTION" },
    { name => "graph_type", label => "_TYPE" } ],
  actions => [
		{ name => "edit", tooltip => "_EDIT",
			link_url => "./report_edit.asp",
      link_args => [ { name => "report", field_value => "name" } ] },
    { name => "remove", tooltip => "_REMOVE",
			link_url => "./dialog.asp", link_type => "popup",
      link_args => [ { name => "id", value => "delete_report" },
                      { name => "arg1", field_value => "name" },
                      { name => "action", value => "remove" }] } ] );

if ($role !~ /ro/i)
{
	my @items = ( { label => "_NEW_REPORT", 
		link => "./report_creation.asp?category=$category" } );
	%><AAT:Menu align="C" items=\@items /><%
}
%>
