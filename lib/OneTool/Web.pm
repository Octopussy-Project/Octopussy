package OneTool::Web;

=head1 NAME

OneTool::Web - OneTool Web module

=cut

use strict;
use warnings;

use FindBin;
use Mojo::Base 'Mojolicious';

use OneTool::Web::LogManagement::Service;

#use OneTool::Web::Wiki::Page;

=head1 SUBROUTINES/METHODS

=head2 startup

=cut

sub startup
{
	my $self = shift;
	
	# loads app configuration
	my $config = $self->plugin('JSONConfig', 
	   { file => "$FindBin::Bin/../conf/octopussy_webconsole.json" });

    # inits Template::Toolkit renderer
	$self->plugin(tt_renderer => { 
		template_options => { 
			PLUGIN_BASE => 'OneTool::Web::Template::Plugin',
			WRAPPER => 'wrapper.tt',
			} 
		});
	$self->renderer->default_handler('tt');

    # inits I18N
	$self->plugin(charset => { charset => 'utf8' });
	$self->plugin(I18N => { namespace => 'OneTool::I18N', default => 'fr' });

    # Hook to redirect to login page when no active session
    $self->hook(
        before_routes => sub {
            my $controller = shift;
            $controller->redirect_to('/user/login')
                if (
                (!defined $controller->session->{user_login})
                && ($controller->req->url->path->to_route !~
                    m{^(?:/user/login|/css/.+|/js/.+)$})
                   );
        }
    );
    
    # sets routes
	my $r = $self->routes;
	
	# Routes /logmanagement/device(s)
#	$r->get('/logmanagement/devices')->to('LogManagement::Device#list');
#	$r->get('/logmanagement/device_models/:device_type')->to('LogManagement::Device#models');
#	$r->get('/logmanagement/device/:device_name/services')->to('LogManagement::Device#services');

    $r->get('/logmanagement/services')->to('LogManagement::Service#list');
    $r->get('/logmanagement/service/:service_name')->to('LogManagement::Service#messages');
    
    $r->get('/logmanagement/table/:table_name')->to('LogManagement::Table#configuration');
    
    $r->any('/user/login')->to('User#login');
    $r->get('/user/logout')->to('User#logout');
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
