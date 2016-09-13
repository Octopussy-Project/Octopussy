<WebUI:PageTopRestricted title="User Preferences" help="user_prefs" />
<%
my $f = $Request->Form();
my $login = $Session->{AAT_LOGIN};
my $ok = 1;
if (defined $f->{update})
{
  	my %conf = ();
	$conf{language} = $f->{AAT_Language};
    $conf{theme} = $f->{AAT_Theme};
    $conf{menu_mode} = $f->{AAT_MenuMode};
  if (NOT_NULL($f->{old_pwd}) || NOT_NULL($f->{new_pwd1})
    || NOT_NULL($f->{new_pwd2}))
  {
    my $auth = AAT::User::Authentication('Octopussy', $login, $f->{old_pwd});
    my $pwd_check = AAT::User::Check_Password_Rules('Octopussy', $f->{new_pwd1});
    if (NULL($auth->{login}))
    {
      $ok = 0;
      %><AAT:Message level="2" msg="Wrong Password !" /><%
    }
    elsif ($f->{new_pwd1} ne $f->{new_pwd2})
    {
      $ok = 0;
      %><AAT:Message level="2" msg="Password Mismatch !" /><%
    }
    elsif ($pwd_check->{status} eq 'KO')
    {
      $ok = 0;
      my $error = $pwd_check->{error};
      %><AAT:Message level="2" msg="$error" /><%
    }
    else
      { $conf{password} = $f->{new_pwd1}; }
  }
  if ($ok)
  {
	AAT::User::Update('Octopussy', $login, $Session->{AAT_USER_TYPE}, \%conf);
    AAT::Language($f->{AAT_Language});
	AAT::Menu_Mode($f->{AAT_MenuMode});
    AAT::Theme($f->{AAT_Theme});
    AAT::Syslog::Message('octo_WebUI', 'USER_PREF_MODIFIED', $Session->{AAT_LOGIN});
    $Response->Redirect('./restricted_user_pref.asp');
  }
}
$Response->Include('AAT/INC/AAT_User_Prefs.inc',
	url => './restricted_user_pref.asp');
%>
<WebUI:PageBottom />
