package OneTool::LogManagement::User;

=head1 NAME

OneTool::LogManagement::User - OneTool LogManagement User module

=cut

use strict;
use warnings;

use Crypt::PasswdMD5;

use OneTool::LogManagement::Configuration;

my $SALT => 'OP';

=head1 SUBROUTINES

=head2 authenticate($login, $password)

Authenticate User from Users file and LDAP Users

=cut

sub authenticate
{
    my ($login, $password) = @_;

    my $conf = OneTool::LogManagement::Configuration::load(undef, 'users');
    #my $md5 = unix_md5_crypt($password, $SALT);
    #printf "MD5: %s\n", $md5;
    my @users = @{$conf->{users}};
    foreach my $u (@users)
    {
        return ($u)
            if (($u->{login} eq $login)
            && ($u->{password} eq $password) #$md5)
            && enabled($u)
            && ($u->{type} eq 'local'));
    }

=head2 TODO
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
=cut
    return (undef);
}

=head2 enabled($user)

Returns 1 if user status is 'enabled' or not defined, else returns 0.

=cut

sub enabled
{
    my $user = shift;

    return (1)
        if ((!defined $user->{status}) || ($user->{status} eq 'Enabled'));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
