package OneTool::Web::LogManagement::Service;

=head1 NAME

OneTool::Web::LogManagement::Service - OneTool Web LogManagement Service module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
#use Mojo::UserAgent;

=head1 SUBROUTINES/METHODS

=head2 list()

=cut

sub list
{
    my $self = shift;
    
    $self->render(template => 'logmanagement/service/list');
}

=head2 messages()

=cut

sub messages
{
    my $self = shift;

    my $service_name = $self->param('service_name');
=head2 comment
    my $config = $self->stash('config');
    my $servers = $config->{modules}->{LogManagement}->{servers};

    my $ua = Mojo::UserAgent->new;
    my @messages = ();
    my @flash_messages = ();
    foreach my $s (@{$servers})
    {
        my $res = $ua->get("$s/service/$service_name")->res;
        if (defined $res->json)
        {
            push @messages, @{$res->json->message};
        }
        else
        {
            push @flash_messages, 
                { 
                type => 'ERROR', 
                msg => "Unable to connect to LogManagement Server $s" 
                };
        }   
    }
    $self->flash(messages => \@flash_messages);
=cut
    #$self->render(text => "Hello $service_name\n");
    $self->render(template => 'logmanagement/service/messages');
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut