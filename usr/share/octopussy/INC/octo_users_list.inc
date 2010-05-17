<%
my %arg = @_;
my $url = $arg{url};
my $url_sort = $url . "?users_table_sort=";
my $sort = $arg{sort};
my $role = $Session->{AAT_ROLE};
%>
<AAT:Box align="C" icon="buttons/bt_users" title="_USERS">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_USER" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_PASSWORD" style="B" /></AAT:BoxCol>
<AAT:BoxCol><!--<AAT:Label value="_CERTIFICATE" style="B" />--></AAT:BoxCol>
<AAT:BoxCol align="C"><AAT:Label value="_LANGUAGE" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_ROLE" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_TYPE" style="B" /></AAT:BoxCol>
<AAT:BoxCol align="C">
<%
if ($role =~ /admin/i)
	{ %><AAT:Label value="_ACTION" style="B" /><% }
%>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $nb_admin = 0;
foreach my $c (AAT::User::Configurations("Octopussy", $sort))
	{ $nb_admin++	if ($c->{role} =~ /^admin$/); }
my $i = 0;
foreach my $c (AAT::User::Configurations("Octopussy", $sort))
{
	my ($login, $certif, $r, $type) = 
		($c->{login}, $c->{certificate}, $c->{role}, $c->{type});
	my $role_name = AAT::User::Role_Name("Octopussy", $r);
	my $flagfile = "AAT/IMG/flags/" . lc($c->{language}) . ".png";
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
	%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$login" no_trans="1"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="--------" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><% 
	if ((NOT_NULL($certif)) && ($certif == 1))
	{
	%>
<!--<AAT:IMG name="generic_keys" width="32" />-->
<%
	}
	%></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Picture file="$flagfile" /></AAT:BoxCol>
	<AAT:BoxCol><%
if (($role_name =~ /restricted/i) && ($role =~ /admin/i))
{
%><AAT:Label value="$role_name" link="./user_restrictions.asp?user=$login" /><%
}
else
	{ %><AAT:Label value="$role_name" /><% } %>
	</AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if ((($role =~ /admin/i) && ($c->{type} =~ /local/))
		&& (($c->{role} !~ /^admin$/) || ($nb_admin > 1)))
  {
		my $dialog = "./dialog.asp?id=delete_user&arg1=$c->{login}";
		%><AAT:Button name="remove" tooltip="_REMOVE" popup_link="$dialog" /><%
	}%>
	</AAT:BoxCol>
	</AAT:BoxRow><%
}

if ($role =~ /admin/i)
{%>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:Form action="$url">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="login" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Password name="password" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><!--<AAT:Selector_YesNo name="certificate" />--></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector_Language /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Selector_User_Role appli="Octopussy" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Form_Submit value="_NEW_USER" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form><%
}
%>
</AAT:Box>
