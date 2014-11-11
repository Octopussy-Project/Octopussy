package OneTool::LogManagement::Server::API::Taxonomy;

=head1 NAME

OneTool::LogManagement::Server::API::Taxonomy - OneTool LogManagement Server API Taxonomy module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use OneTool::LogManagement::Configuration;

=head2 configuration()

Returns Taxonomy configuration

=cut

sub configuration
{
    my $self = shift;

    my $conf = OneTool::LogManagement::Configuration::get(undef, 'taxonomy');

    $self->render(json => $conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
