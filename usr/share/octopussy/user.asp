<WebUI:PageTop title="_USERS" help="users" />
<%
my $f = $Request->Form();
my $login = $f->{login} || $Request->QueryString("login");
$login = (($login =~ /^[a-z][a-z0-9_\.-]*$/i) ? $login : undef);
my $action = $Request->QueryString("action");
my $sort = $Request->QueryString("users_table_sort");

if (($action eq "remove") && ($Session->{AAT_ROLE} =~ /admin/i))
{
  AAT::User::Remove("Octopussy", $login);
  AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "User", $login, $Session->{AAT_LOGIN});
  $Response->Redirect("./user.asp");
}
elsif ((NOT_NULL($login)) && ($Session->{AAT_ROLE} !~ /ro/i))
{
	$Session->{AAT_MSG_ERROR} =
    AAT::User::Add("Octopussy", $login, $f->{password}, 
			$f->{certificate}, $f->{user_role}, $f->{AAT_Language}, $f->{status});
  AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "User", $login, $Session->{AAT_LOGIN})
  	if (NOT_NULL($Session->{AAT_MSG_ERROR}));
	if ($f->{certificate} == 1)
 	{
  	my %conf = ( country => "FR", state => "Ile de France", city => "Paris",
        organization => "Octopussy Project", organizational_unit => "Devel",
        common_name => "$login Octopussy Client Certificate", 
				email => "octo.devel\@gmail.com" );
   	AAT::Certificate::Client_Create("Octopussy", "$login", 
			$f->{password}, \%conf);

   	$Response->{ContentType} = "text/p12";
   	$Response->AddHeader('Content-Disposition', "filename=\"${login}.p12\"");
   	open(FILE, "< ${login}.p12");
   	while (<FILE>)
   		{ print $_; }
   	$Response->End();
	}
	$Response->Redirect("./user.asp");
}
%>
<AAT:Inc file="octo_users_list" url="./user.asp" sort="$sort" />
<WebUI:PageBottom />
