package OneTool::Web::Template::Plugin::LogManagement::Service;

=head1 NAME

OneTool::Web::Template::Plugin::LogManagement::Service

=cut

use strict;
use warnings;
use base 'Template::Plugin';

use Mojo::UserAgent;

=head1 SUBROUTINES/METHODS

=head2 new()

=cut

sub new
{
    my ($class, $context, $params) = @_;

    bless {
        _CONTEXT 	=> $context,
		config		=> $params,
		ua          => Mojo::UserAgent->new()
    }, $class;
}

=head2 configuration($sort)

=cut

sub configuration
{
    my ($self, $service_name) = @_;

    my $servers = $self->{config}->{applications}->{LogManagement}->{servers};

    foreach my $s (@{$servers})
    {
        my $res = $self->{ua}->get("$s/service/${service_name}")->res;
        return ($res->json) if (defined $res->json);
    }

    return (undef);
}

sub list
{
    my $self = shift;
    
    my $servers = $self->{config}->{applications}->{LogManagement}->{servers};

    foreach my $s (@{$servers})
    {
        my $res = $self->{ua}->get("$s/services")->res;
        return ($res->json) if (defined $res->json);
    }

    return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
