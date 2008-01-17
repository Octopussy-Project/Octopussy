<AAT:PageTop title="Octopussy Login" icon="IMG/octopussy.gif" />
<AAT:PageTheme />
<%
my $f = $Request->Form();

if ((defined $f->{login}) && (defined $f->{password}))
{
	my $auth_login = AAT::User::Authentication($f->{login}, $f->{password});
 	if (defined $auth_login->{login})
 	{
  	$Session->{AAT_LOGIN} = $auth_login->{login};
		$Session->{AAT_PASSWORD} = $f->{password};
		$Session->{AAT_ROLE} = $auth_login->{role};
		$Session->{AAT_LANGUAGE} = $auth_login->{language};
		$Session->{AAT_THEME} = $auth_login->{theme};
		AAT::Syslog("octo_WebUI", "USER_LOGGED_IN");
 	}
 	else
 	{
		$Session->{AAT_MSG_ERROR} = "_MSG_INVALID_LOGIN_PASSWORD";
		AAT::Syslog("octo_WebUI", "USER_FAILED_LOGIN");
  	$Response->Redirect("./login.asp");
 	}
	my $redirect = ($auth_login->{role} =~  /restricted/i 
		? "./restricted_logs_viewer.asp" : "./index.asp");
	$Response->Redirect($redirect);
}
%>
<AAT:Inc file="octo_login" />
<AAT:Msg_Error />
<AAT:PageBottom credits="1" />
