<AAT:PageTop title="Octopussy Login" icon="IMG/octopussy.gif" />
<AAT:PageTheme />
<!--<link rel="jetpack" href="jetpack.js" name="Octopussy JetPack"/>-->
<%
my $f = $Request->Form();
my $page = $Request->QueryString("redirect");
$page =~ s/^\///;

if ((defined $f->{login}) && (defined $f->{password}))
{
	my $auth = 
		AAT::User::Authentication("Octopussy", $f->{login}, $f->{password});
 	if (defined $auth->{login})
 	{
		$Session->{Timeout} = 60;
  		$Session->{AAT_LOGIN} = $auth->{login}; 
		$Session->{AAT_ROLE} = $auth->{role};
		if ($auth->{role} eq 'restricted')
		{ 	# restricted user -> get devices & services restrictions
			my $restrictions = AAT::User::Restrictions('Octopussy', $auth->{login});
  			$Session->{restricted_devices} = $restrictions->{device};
  			$Session->{restricted_services} = $restrictions->{service};
  			$Session->{restricted_minutes_search} = $restrictions->{max_minutes_search};
		}
		$Session->{AAT_LANGUAGE} = $auth->{language};
		$Session->{AAT_THEME} = $auth->{theme};
		$Session->{AAT_MENU_MODE} = $auth->{menu_mode};
		AAT::Translation::Init($Session->{AAT_LANGUAGE});
		AAT::Syslog("octo_WebUI", "USER_LOGGED_IN");
 	}
 	else
 	{
		$Session->{AAT_MSG_ERROR} = "_MSG_INVALID_LOGIN_PASSWORD";
		AAT::Syslog("octo_WebUI", "USER_FAILED_LOGIN");
  	$Response->Redirect("./login.asp");
 	}
	my $redirect = (($auth->{role} =~  /restricted/i) 
		? "./restricted_logs_viewer.asp" 
		: (AAT::NOT_NULL($page) ? "./$page" : "./index.asp"));
	$Response->Redirect($redirect);
}
%>
<AAT:Inc file="octo_login" redirect="$page" />
<AAT:Msg_Error />
<AAT:PageBottom />
