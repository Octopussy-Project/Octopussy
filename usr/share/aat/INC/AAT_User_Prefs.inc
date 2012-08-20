<%
my %arg = @_;
my $url = $arg{url};
my $login = $Session->{AAT_LOGIN};
my $user_type = $Session->{AAT_USER_TYPE};
%>
<AAT:Form method="POST" action="$url">
<AAT:Box icon="buttons/bt_user_prefs" title="_USER_PREFS" align="center">
	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Button name="user" /></AAT:BoxCol>
    <AAT:BoxCol align="left">
		<AAT:Label value="_USER" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$login" /></AAT:BoxCol>
  </AAT:BoxRow>
<%
if ($user_type eq 'local')
{%>
	<AAT:BoxRow>
		<AAT:BoxCol rspan="3"><AAT:Button name="locked" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Label value="_PASSWORD" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Password name="old_pwd" size="12" />
		</AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_NEW_PASSWORD" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Password name="new_pwd1" size="12" />
    </AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_NEW_PASSWORD" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Password name="new_pwd2" size="12" />
    </AAT:BoxCol>
  </AAT:BoxRow>
<%
}
%>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Button name="keyboard_layout" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="_LANGUAGE" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Selector_Language /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Button name="theme" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Label value="_THEME" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Selector_Theme /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow>
    <AAT:BoxCol><AAT:Button name="menu_config" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Label value="_MENU_DISPLAY" /></AAT:BoxCol>
    <AAT:BoxCol><AAT:Selector_MenuMode /></AAT:BoxCol>
  </AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol cspan="3" align="center">
		<AAT:Form_Hidden name="update" value="1" />
		<AAT:Form_Submit value="_MSG_UPDATE_PREFS" /></AAT:BoxCol>
	</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
