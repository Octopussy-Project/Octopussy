=head1 NAME

AAT::User - AAT User module

=cut
package AAT::User;

use strict;

use Crypt::PasswdMD5;

my $SALT = "OP";

my $DEFAULT_LANGUAGE = "EN";
my $DEFAULT_ROLE = "rw";
my $DEFAULT_THEME = "DEFAULT";
my $ROLES_FILE = undef;
my $USERS_FILE = undef;

my %roles = ();

=head1 FUNCTIONS

=head2 Authentication($login, $pwd)

Check Authentication from Users file and LDAP Users

=cut

sub Authentication($$)
{
  my ($login, $pwd) = @_;

	$USERS_FILE ||= Octopussy::File("users");
	my $conf = AAT::XML::Read($USERS_FILE);
  my $md5 = unix_md5_crypt($pwd, $SALT);
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
    return ($u) if (($u->{login} eq $login) && ($u->{password} eq $md5));
  }

  if (AAT::LDAP::Check_Password($login, $pwd))
  {
    return ({ login => $login, password => $pwd, role => $DEFAULT_ROLE,
      language => $DEFAULT_LANGUAGE, theme => $DEFAULT_THEME });
  }

  return (undef);
}

=head2 Add($login, $pwd, $role, $lang)

Adds user with '$login', '$pwd', '$role' and '$lang'

=cut

sub Add($$$$)
{
	my ($login, $pwd, $role, $lang) = @_;

	$USERS_FILE ||= Octopussy::File("users");
	my $conf = AAT::XML::Read($USERS_FILE);
  foreach my $u (AAT::ARRAY($conf->{user}))
    { return ("_MSG_USER_ALREADY_EXISTS") if ($u->{login} eq $login); }
  push(@{$conf->{user}}, { login => $login,
    password => unix_md5_crypt($pwd, $SALT), role => $role,
    language => $lang || $DEFAULT_LANGUAGE, theme => $DEFAULT_THEME });
  AAT::XML::Write($USERS_FILE, $conf, "octopussy_users");

  return (undef);	
}

=head2 Remove($login)

Removes User with login '$login'

=cut

sub Remove($)
{
  my $login = shift;

	$USERS_FILE ||= Octopussy::File("users");
  my $conf = AAT::XML::Read($USERS_FILE);
  my @users = ();
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
    push(@users, $u)       if ($u->{login} ne $login);
  }
  $conf->{user} = \@users;
  AAT::XML::Write($USERS_FILE, $conf, "octopussy_users");
}

=head2 Update($login, $update)

Updates user '$login' with configuration '$update'

=cut

sub Update($$)
{
  my ($login, $update) = @_;

	$USERS_FILE ||= Octopussy::File("users");
  my $conf = AAT::XML::Read($USERS_FILE);
  my @users = ();
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
    if ($u->{login} ne $login)
    {
      push(@users, $u);
    }
    else
    {
      my $pwd = unix_md5_crypt($update->{password}, $SALT);
      push(@users, { login => $update->{login}, password => $pwd,
        role => $update->{role}, language => $update->{language},
        theme => $update->{theme}, restriction => $u->{restrictions} });
    }
  }
  $conf->{user} = \@users;
  AAT::XML::Write($USERS_FILE, $conf, "octopussy_users");
}

=head2 Restrictions($login)

Returns User Restrictions for User '$login'

=cut

sub Restrictions($)
{
	my $login = shift;

	$USERS_FILE ||= Octopussy::File("users");
  my $conf = AAT::XML::Read($USERS_FILE);
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
  	return ($u->{restrictions}[0])	if ($u->{login} eq $login);
  }

	return (undef);
}

=head2 Update_Restrictions($login, $restrictions)

Updates restrictions '$restrictions' to user '$login'

=cut

sub Update_Restrictions($$)
{
	my ($login, $restrictions) = @_;

  $USERS_FILE ||= Octopussy::File("users");
  my $conf = AAT::XML::Read($USERS_FILE);
  my @users = ();
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
    if ($u->{login} ne $login)
    {
      push(@users, $u);
    }
    else
    {
			$u->{restrictions} = $restrictions;
      push(@users, $u);
    }
  }
  $conf->{user} = \@users;
  AAT::XML::Write($USERS_FILE, $conf, "octopussy_users");	
}

=head2 List()

Lists all Users (from file & LDAP)

=cut

sub List()
{
	$USERS_FILE ||= Octopussy::File("users");
  my $conf = AAT::XML::Read($USERS_FILE);
  my @users = ();
  foreach my $u (AAT::ARRAY($conf->{user}))
  {
    $u->{type} = "local";
    push(@users, $u);
  }
  my @ldap_users = AAT::LDAP::Users();
  foreach my $u (@ldap_users)
    { push(@users, $u); }

  return (@users);
}

=head2 Configurations($sort)

Returns configurations for all Users

=cut

sub Configurations
{
  my $sort = shift;
  my (@configurations, @sorted_configurations) = ((), ());
  my @users = List();
  my %field;

  foreach my $conf (@users)
  {
    $field{$conf->{$sort}} = 1;
    push(@configurations, $conf);
  }
  foreach my $f (sort keys %field)
  {
    foreach my $c (@configurations)
      { push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
  }

  return (@sorted_configurations);
}

=head2 Roles_Init()

Inits Users Roles

=cut

sub Roles_Init()
{
	$ROLES_FILE ||= Octopussy::File("user_roles");
	my $conf = AAT::XML::Read($ROLES_FILE);
	foreach my $r (AAT::ARRAY($conf->{role}))
		{ $roles{$r->{value}}{label} = $r->{label}; }	
}

=head2 Roles_Configurations()

Returns Users Roles Configurations

=cut

sub Roles_Configurations()
{
	$ROLES_FILE ||= Octopussy::File("user_roles");
	my $conf = AAT::XML::Read($ROLES_FILE);

	return (AAT::ARRAY($conf->{role}))
}

=head2 Role_Name($role)

Returns name of a role

=cut

sub Role_Name($)
{
	my $role = shift;
	
	Roles_Init()	if (! %roles);

	return ($roles{$role}{label}); 
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
