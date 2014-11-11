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

    # sets routes
	my $r = $self->routes;
	
	# Routes /logmanagement/device(s)
#	$r->get('/logmanagement/devices')->to('LogManagement::Device#list');
#	$r->get('/logmanagement/device_models/:device_type')->to('LogManagement::Device#models');
#	$r->get('/logmanagement/device/:device_name/services')->to('LogManagement::Device#services');

    $r->get('/logmanagement/services')->to('LogManagement::Service#list');
    $r->get('/logmanagement/service/:service_name')->to('LogManagement::Service#messages');
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
