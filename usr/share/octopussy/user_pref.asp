<WebUI:PageTop title="User Preferences" help="user_prefs"/>
<%
my $f = $Request->Form();
my $login = $Session->{AAT_LOGIN};
my $ok = 1;
if (defined $f->{update})
{
	my %conf = ();
	if (AAT::NOT_NULL($f->{old_pwd}) || AAT::NOT_NULL($f->{new_pwd1}) 
		|| AAT::NOT_NULL($f->{new_pwd2}))
	{
		my $auth = AAT::User::Authentication("Octopussy", $login, $f->{old_pwd});
    if (AAT::NULL($auth->{login}))
    { 
			$ok = 0;
			%><AAT:Message level="2" msg="Wrong Password !" /><% 
		}
		elsif ($f->{new_pwd1} ne $f->{new_pwd2})
		{ 
			$ok = 0;
			%><AAT:Message level="2" msg="Password Mismatch !" /><% 
		}
		else
			{ $conf{password} = $f->{new_pwd1}; }
	}
	else
	{
  	$conf{language} = $f->{AAT_Language};
		$conf{theme} = $f->{AAT_Theme};
	}
	if ($ok)
	{
 		AAT::User::Update("Octopussy", $login, \%conf);
 		AAT::Language($f->{AAT_Language});
 		AAT::Theme($f->{AAT_Theme});
		AAT::Syslog("octo_WebUI", "USER_PREF_MODIFIED");
		$Response->Redirect("./user_pref.asp");
	}
}
$Response->Include("AAT/INC/AAT_User_Prefs.inc", url => "./user_pref.asp");
%>
<WebUI:PageBottom />
