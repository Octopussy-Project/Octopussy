<%
my %arg = @_;
my $url = $arg{url};
my $login = $arg{user};
my $conf = AAT::User::Configuration('Octopussy', $login);
my ($pwd, $language, $role, $status) = 
	($conf->{password}, $conf->{language}, $conf->{role}, $conf->{status});
%>
<AAT:Form method="POST" action="$url">
<AAT:Box icon="buttons/bt_user" title="_USER_EDIT" align="center">
	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Button name="user" /></AAT:BoxCol>
    	<AAT:BoxCol align="left"><AAT:Label value="_USER" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="$login" /></AAT:BoxCol>
		<AAT:Form_Hidden name="login" value="$login" />
  	</AAT:BoxRow>
  	<AAT:BoxRow>
		<AAT:BoxCol><AAT:Button name="locked" /></AAT:BoxCol>
    	<AAT:BoxCol><AAT:Label value="_PASSWORD" /></AAT:BoxCol>
    	<AAT:BoxCol><AAT:Password name="password" size="12" value="" /></AAT:BoxCol>
  	</AAT:BoxRow>
  	<AAT:BoxRow>
    	<AAT:BoxCol><AAT:Button name="keyboard_layout" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Label value="_LANGUAGE" /></AAT:BoxCol>
    	<AAT:BoxCol><AAT:Selector_Language selected="$language" /></AAT:BoxCol>
  	</AAT:BoxRow>
  	<AAT:BoxRow>
  		<AAT:BoxCol></AAT:BoxCol>
  		<AAT:BoxCol><AAT:Label value="_ROLE" /></AAT:BoxCol>
  		<AAT:BoxCol><AAT:Selector_User_Role appli="Octopussy" selected="$role" /></AAT:BoxCol>
  	</AAT:BoxRow>
  	<AAT:BoxRow>
  		<AAT:BoxCol></AAT:BoxCol>
  		<AAT:BoxCol><AAT:Label value="_STATUS" /></AAT:BoxCol>
		<AAT:BoxCol><AAT:Selector_EnabledDisabled name="status" selected="$status" /></AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
		<AAT:BoxCol cspan="3" align="center">
		<AAT:Form_Hidden name="update" value="1" />
		<AAT:Form_Submit value="_SAVE" /></AAT:BoxCol>
	</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
