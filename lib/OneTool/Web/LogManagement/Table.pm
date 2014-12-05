package OneTool::Web::LogManagement::Table;

=head1 NAME

OneTool::Web::LogManagement::Table - OneTool Web LogManagement Table module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
#use Mojo::UserAgent;

=head1 SUBROUTINES/METHODS

=head2 configuration()

=cut

sub configuration
{
    my $self = shift;
    
    $self->render(template => 'logmanagement/table/configuration');
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut