package OneTool::LogManagement::Server::API::Service;

=head1 NAME

OneTool::LogManagement::Server::API::Service - OneTool LogManagement Server API Service module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use OneTool::LogManagement::Service;

=head2 configuration()

Returns Service configuration

=cut

sub configuration
{
    my $self = shift;

    my $service_name = $self->param('service_name');
    my $conf = OneTool::LogManagement::Service::configuration($service_name);

    $self->render(json => $conf);
}

=head2 list()

Returns Services list

=cut

sub list
{
    my $self = shift;

    my @list = OneTool::LogManagement::Service::list();

    $self->render(json => \@list);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
