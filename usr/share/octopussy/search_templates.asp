<WebUI:PageTop title="Search Templates" help="#search_templates" />
<%
my $action = $Request->QueryString("action");
my $user = $Request->QueryString("user");
$user = (($user =~ /^[a-z][a-z0-9_\.-]*$/i) ? $user : undef);
my $template = $Request->QueryString("template");
$template = (Octopussy::Search_Template::Valid_Name($template) 
	? $template : undef);
my $sort = $Request->QueryString("search_templates_table_sort");
if (NOT_NULL($action) && ($action eq "remove") 
	&& ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
{
	Octopussy::Search_Template::Remove($user, $template);	
	$Session->{template} = undef;
}
%>
<AAT:Inc file="octo_search_templates_list" 
	url="./search_templates.asp" sort="$sort" />
<WebUI:PageBottom />
