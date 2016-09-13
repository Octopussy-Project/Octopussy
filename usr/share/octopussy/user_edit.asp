<%
$Response->Redirect('./login.asp?redirect=/user.asp')
    if ((NULL($Session->{AAT_LOGIN}))
		|| ($Session->{AAT_ROLE} eq 'restricted'));
my $f = $Request->Form();
my $login = $Request->QueryString('user') || $f->{login};
my $type = $Request->QueryString('type') || $f->{type};
my $error = undef;

if ((defined $f->{update}) && ($Session->{AAT_ROLE} =~ /^admin$/i))
{
  my $pwd_check = AAT::User::Check_Password_Rules('Octopussy', $f->{password});
  if ($pwd_check->{status} eq 'OK')
  {
 	  AAT::User::Update('Octopussy', $f->{login}, $f->{type},
 		 { 	   password => $f->{password},
			     language => $f->{AAT_Language},
			     role => $f->{user_role},
			      status => $f->{status}, }
		          );
	  $Response->Redirect('./user.asp');
  }
  else
  {
    $error = $pwd_check->{error};
  }
}
%>
<WebUI:PageTop title="_USER_PREFS" help="users" />
<%
if (defined $error)
{
  %><AAT:Message level="2" msg="$error" /><%
}
%>
<AAT:Inc file="octo_user_edit" user="$login" type="$type" url="./user_edit.asp" />
<WebUI:PageBottom />
