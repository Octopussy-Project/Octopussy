package OneTool::Web::User;

=head1 NAME

OneTool::Web::User - OneTool Web User module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use OneTool::LogManagement::User;

=head1 SUBROUTINES/METHODS

=head2 login()

=cut

sub login
{
    my $c = shift;
    
    my $login = $c->param('login');
    my $password = $c->param('password');

    my $user = OneTool::LogManagement::User::authenticate($login, $password);
    if (defined $user)
    {
        $c->session(user_login => $user->{login});
        $c->flash(message => "Welcome $login !");

        $c->redirect_to('/logmanagement/service/octopussy');
    }
    else
    {
        $c->render(template => 'user/login');
    }
}

=head2 logout()

=cut

sub logout
{
    my $c = shift;

    $c->session(expires => 1);

    $c->redirect_to('/user/login');
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut