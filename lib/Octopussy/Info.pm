
=head1 NAME

Octopussy::Info - Octopussy Information module

=cut

package Octopussy::Info;

use strict;
use warnings;

use Readonly;

use AAT::Application;

Readonly my $APPLICATION_NAME => 'Octopussy';

=head1 FUNCTIONS

=head2 Email()

Returns Octopussy Support Email

=cut

sub Email
{
    my $info = AAT::Application::Info($APPLICATION_NAME);

    return ($info->{email});
}

=head2 User()

Returns Octopussy System User

=cut

sub User
{
    my $info = AAT::Application::Info($APPLICATION_NAME);

    return ($info->{user});
}

=head2 WebSite()

Returns Octopussy WebSite

=cut

sub WebSite
{
    my $info = AAT::Application::Info($APPLICATION_NAME);

    return ($info->{website});
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
