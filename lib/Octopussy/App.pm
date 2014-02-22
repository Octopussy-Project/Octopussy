package Octopussy::App;

use AAT::Syslog;
use Octopussy::Info;

=head1 SUBROUTINES/METHODS

=head2 Valid_User($prog_name)

Checks that current user is Octopussy user for program $prog_name

=cut

sub Valid_User
{
    my $prog_name = shift;

    my @info      = getpwuid $<;
    my $octo_user = Octopussy::Info::User();

    return (1) if ($info[0] =~ /^$octo_user$/);

    AAT::Syslog::Message($prog_name,
        "You have to be Octopussy user to use $prog_name");
    printf "You have to be Octopussy user to use %s !\n", $prog_name;

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
