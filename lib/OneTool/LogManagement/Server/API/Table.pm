package OneTool::LogManagement::Server::API::Table;

=head1 NAME

OneTool::LogManagement::Server::API::Table - OneTool LogManagement Server API Table module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use OneTool::LogManagement::Table;

=head2 configuration()

Returns Table configuration

=cut

sub configuration
{
    my $self = shift;

    my $table_name = $self->param('table_name');
    my $conf = OneTool::LogManagement::Table::configuration($table_name);

    $self->render(json => $conf);
}

=head2 list()

Returns Tables list

=cut

sub list
{
    my $self = shift;

    my @list = OneTool::LogManagement::Table::list();

    $self->render(json => \@list);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
