package OneTool::LogManagement::Server::API::Loglevel;

=head1 NAME

OneTool::LogManagement::Server::API::Loglevel - OneTool LogManagement Server API Loglevel module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use OneTool::LogManagement::Configuration;

=head2 configuration()

Returns Loglevel configuration

=cut

sub configuration
{
    my $self = shift;

    my $conf = OneTool::LogManagement::Configuration::get(undef, 'loglevel');

    $self->render(json => $conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
