package OneTool::LogManagement::Server::API;

=head1 NAME

OneTool::LogManagement::Server::API - OneTool LogManagement Server API module

=cut

use strict;
use warnings;

use Mojo::Base 'Mojolicious';

=head1 SUBROUTINES/METHODS

=head2 startup

=cut

sub startup
{
	my $self = shift;

	my $r = $self->routes;

	# Routes /device(s)
	#$r->get('/device/:device_name')->to('device#configuration');
	#$r->post('/device/:device_name')->to('device#new');
	#$r->get('/devices')->to('device#list');

	#$r->get('/device_models/:device_type')->to('device#models');
    #$r->get('/device_types')->to('device#types');
	# Routes /logs
	#$r->get('/logs/:begin/:end/:device_selection/:service_selection')->to('logs#extraction');

	# Routes /service(s)
	$r->get('/service/:service_name')->to('service#configuration');
	$r->get('/services')->to('service#list');
	
	# Routes /table(s)
    $r->get('/table/:table_name')->to('table#configuration');
    $r->get('/tables')->to('table#list');
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
