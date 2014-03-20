
=head1 NAME

AAT::User - AAT User module

=cut

package AAT::User;

use strict;
use warnings;
use Readonly;
use Crypt::PasswdMD5;

use AAT::Application;
use AAT::LDAP;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;

Readonly my $SALT              => 'OP';
Readonly my $DEFAULT_LANGUAGE  => 'EN';
Readonly my $DEFAULT_MENU_MODE => 'TEXT_AND_ICONS';
Readonly my $DEFAULT_ROLE      => 'rw';
Readonly my $DEFAULT_STATUS    => 'Enabled';
Readonly my $DEFAULT_THEME     => 'DEFAULT';

my $ROLES_FILE = undef;
my $USERS_FILE = undef;

my %roles = ();

=head1 FUNCTIONS

=head2 Authentication($appli, $login, $pwd)

Check Authentication from Users file and LDAP Users

=cut

sub Authentication
{
    my ($appli, $login, $pwd) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf = AAT::XML::Read($USERS_FILE);
    my $md5 = unix_md5_crypt($pwd, $SALT);
    foreach my $u (ARRAY($conf->{user}))
    {
        return ($u)
            if (($u->{login} eq $login)
            && ($u->{password} eq $md5)
            && Enabled($u)
            && ($u->{type} eq 'local'));
    }

    if (AAT::LDAP::Check_Password($appli, $login, $pwd))
    {
        foreach my $u (ARRAY($conf->{user}))
        {
            return ($u)
                if (($u->{login} eq $login)
                && Enabled($u)
                && ($u->{type} eq 'LDAP'));
        }

        # LDAP User connects for the first time
        Add($appli, $login, undef, undef, $DEFAULT_ROLE, $DEFAULT_LANGUAGE,
            $DEFAULT_STATUS, 'LDAP');
        $conf = AAT::XML::Read($USERS_FILE);
        foreach my $u (ARRAY($conf->{user}))
        {
            return ($u)
                if (($u->{login} eq $login)
                && Enabled($u)
                && ($u->{type} eq 'LDAP'));
        }
    }

    return (undef);
}

=head2 Add($appli, $login, $pwd, $certificate, $role, $lang, $status, $type)

Adds user with '$login', '$pwd', '$role' and '$lang'

=cut

sub Add
{
    my ($appli, $login, $pwd, $certificate, $role, $lang, $status, $type) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf = AAT::XML::Read($USERS_FILE);
    foreach my $u (ARRAY($conf->{user}))
    {
        return ('_MSG_USER_ALREADY_EXISTS')
            if (($u->{login} eq $login) && ($u->{type} eq $type));
    }
    push @{$conf->{user}},
        {
        login       => $login,
        password    => (defined $pwd ? unix_md5_crypt($pwd, $SALT) : undef),
        certificate => $certificate,
        role     => $role   || $DEFAULT_ROLE,
        language => $lang   || $DEFAULT_LANGUAGE,
        status   => $status || $DEFAULT_STATUS,
        theme    => $DEFAULT_THEME,
        menu_mode => $DEFAULT_MENU_MODE,
        type      => $type || 'local',
        };
    AAT::XML::Write($USERS_FILE, $conf, "${appli}_users");

    return (undef);
}

=head2 Remove($appli, $login)

Removes User with login '$login'

=cut

sub Remove
{
    my ($appli, $login) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf  = AAT::XML::Read($USERS_FILE);
    my @users = ();
    foreach my $u (ARRAY($conf->{user}))
    {
        push @users, $u if (($u->{login} ne $login) || ($u->{type} eq 'LDAP'));
    }
    $conf->{user} = \@users;
    AAT::XML::Write($USERS_FILE, $conf, "${appli}_users");

    return (scalar @users);
}

=head2 Update($appli, $login, $type, $update)

Updates user '$login' with configuration '$update'

=cut

sub Update
{
    my ($appli, $login, $type, $update) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf    = AAT::XML::Read($USERS_FILE);
    my @users   = ();
    my $updated = 0;
    foreach my $u (ARRAY($conf->{user}))
    {
        if (($u->{login} eq $login) && ($u->{type} eq $type))
        {
            my $pwd = (
                  NOT_NULL($update->{password})
                ? unix_md5_crypt($update->{password}, $SALT)
                : $u->{password}
            );
            push @users,
                {
                login => $update->{login} || $login,
                password => $pwd,
                role     => $update->{role} || $u->{role},
                language => $update->{language} || $u->{language},
                status   => $update->{status} || $u->{status} || 'Enabled',
                theme     => $update->{theme}     || $u->{theme},
                menu_mode => $update->{menu_mode} || $u->{menu_mode},
                restrictions => $u->{restrictions},
                type         => $type || 'local',
                };
            $updated = 1;
        }
        else
        {
            push @users, $u;
        }
    }
    if ($updated)
    {
        $conf->{user} = \@users;
        AAT::XML::Write($USERS_FILE, $conf, "${appli}_users");
    }
    else
    {
        Add($appli, $login, undef, undef, $update->{role}, $update->{language},
            $update->{status} || 'Enabled', $type);
    }

    return (scalar @users);
}

=head2 Restrictions($appli, $login, $type)

Returns User Restrictions for User '$login'

=cut

sub Restrictions
{
    my ($appli, $login, $type) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf = AAT::XML::Read($USERS_FILE);
    foreach my $u (ARRAY($conf->{user}))
    {
        return ($u->{restrictions}[0])
            if (($u->{login} eq $login)
            && ($u->{type} eq $type)
            && (NOT_NULL($u->{restrictions})));
    }

    return (undef);
}

=head2 Update_Restrictions($appli, $login, $type, $restrictions)

Updates restrictions '$restrictions' to user '$login'

=cut

sub Update_Restrictions
{
    my ($appli, $login, $type, $restrictions) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf  = AAT::XML::Read($USERS_FILE);
    my @users = ();
    foreach my $u (ARRAY($conf->{user}))
    {
        if (($u->{login} eq $login) && ($u->{type} eq $type))
        {
            $u->{restrictions} = $restrictions;
        }
        push @users, $u;
    }
    $conf->{user} = \@users;
    AAT::XML::Write($USERS_FILE, $conf, "${appli}_users");

    return (scalar @users);
}

=head2 List($appli)

Lists all Users (from file & LDAP)

=cut

sub List
{
    my $appli = shift;

    my %ldap_local = ();
    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf  = AAT::XML::Read($USERS_FILE);
    my @users = ();
    foreach my $u (ARRAY($conf->{user}))
    {
        push @users, $u;
        $ldap_local{$u->{login}} = 1 if ($u->{type} eq 'LDAP');
    }
    my @ldap_users = AAT::LDAP::Users($appli);
    foreach my $u (@ldap_users)
    {
        push @users, $u if (!defined $ldap_local{$u->{login}});
    }

    return (@users);
}

=head2 Configuration($appli, $login, $type)

Returns configuration for user '$login'

=cut

sub Configuration
{
    my ($appli, $login, $type) = @_;

    $USERS_FILE ||= AAT::Application::File($appli, 'users');
    my $conf = AAT::XML::Read($USERS_FILE);
    foreach my $u (ARRAY($conf->{user}))
    {
        return ($u) if (($u->{login} eq $login) && ($u->{type} eq $type));
    }

    return (undef);
}

=head2 Configurations($appli, $sort)

Returns configurations for all Users

=cut

sub Configurations
{
    my ($appli, $sort) = @_;
    my @sorted_configurations = ();
    my @users                 = List($appli);
    $sort = (NOT_NULL($sort) ? lc($sort) : 'login');

    foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @users)
    {
        push @sorted_configurations, $c;
    }

    return (@sorted_configurations);
}

=head2 Enabled($user)

Returns 1 if user status is 'Enabled' or not defined, else returns 0.

=cut

sub Enabled
{
    my $user = shift;

    return (1)
        if ((!defined $user->{status}) || ($user->{status} eq 'Enabled'));
    return (0);
}

=head2 Roles_Init($appli)

Inits Users Roles

=cut

sub Roles_Init
{
    my $appli = shift;

    $ROLES_FILE ||= AAT::Application::File($appli, 'user_roles');
    my $conf = AAT::XML::Read($ROLES_FILE);
    foreach my $r (ARRAY($conf->{role}))
    {
        $roles{$r->{value}}{label} = $r->{label};
    }

    return (scalar ARRAY($conf->{role}));
}

=head2 Roles_Configurations($appli)

Returns Users Roles Configurations

=cut

sub Roles_Configurations
{
    my $appli = shift;

    $ROLES_FILE ||= AAT::Application::File($appli, 'user_roles');
    my $conf = AAT::XML::Read($ROLES_FILE);

    return (ARRAY($conf->{role}));
}

=head2 Role_Name($appli, $role)

Returns name of a role

=cut

sub Role_Name
{
    my ($appli, $role) = @_;

    Roles_Init($appli) if (!%roles);

    return ($roles{$role}{label});
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
