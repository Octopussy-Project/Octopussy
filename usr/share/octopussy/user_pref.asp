<WebUI:PageTop title="User Preferences" help="user_prefs"/>
<%
my $f = $Request->Form();
my $login = $Session->{AAT_LOGIN};

if (defined $f->{update})
{
  my $role = $Session->{AAT_ROLE};
  my $conf = { login => $login, password => $f->{pword}, role => $role,
    language => $f->{AAT_Language}, theme => $f->{AAT_Theme} };
  AAT::User::Update($login, $conf);
  AAT::Language($f->{AAT_Language});
  AAT::Theme($f->{AAT_Theme});
	AAT::Syslog("octo_WebUI", "USER_PREF_MODIFIED");
	$Response->Redirect("./user_pref.asp");
}
$Response->Include("AAT/INC/AAT_User_Prefs.inc", url => "./user_pref.asp");
%>
<WebUI:PageBottom />
