<WebUI:PageTop title="Search Templates" help="#search_templates" />
<%
my $role = $Session->{AAT_ROLE};
my $action = $Request->QueryString("action");
my $user = $Request->QueryString("user");
my $template = $Request->QueryString("template");
my $sort = $Request->QueryString("search_templates_table_sort");
if (AAT::NOT_NULL($action) && ($action eq "remove") && ($role !~ /ro/i))
{
	Octopussy::Search_Template::Remove($user, $template);	
	$Session->{template} = undef;
}
%>
<AAT:Inc file="octo_search_templates_list" 
	url="./search_templates.asp" sort="$sort" />
<WebUI:PageBottom />
