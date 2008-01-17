<WebUI:PageTop title="User" help="users" />
<%
my $f = $Request->Form();
my $login = $f->{login} || $Request->QueryString("login");
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("users_table_sort");

if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /admin/i))
{
  AAT::User::Remove($login);
	AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "User", $login);
  $Response->Redirect("./user.asp");
}
elsif (!defined $login)
{
	%><AAT:Inc file="octo_users_list" url="./user.asp" sort="$sort" /><%
}
else
{
	if ($Session->{AAT_ROLE} !~ /ro/i)
	{
		$Session->{AAT_MSG_ERROR} = 
		AAT::User::Add($login, $f->{password}, $f->{user_role}, 
			$f->{AAT_Language});
		AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "User", $login)
			if (AAT::NOT_NULL($Session->{AAT_MSG_ERROR}));
	}
	$Response->Redirect("./user.asp");
}
%>
<WebUI:PageBottom />
