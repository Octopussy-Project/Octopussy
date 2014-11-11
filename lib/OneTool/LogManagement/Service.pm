package OneTool::LogManagement::Service;

=head1 NAME

OneTool::LogManagement::Service - OneTool LogManagement Service module

=cut

use strict;
use warnings;

use OneTool::LogManagement::Configuration;

=head1 SUBROUTINES/METHODS

=head2 configuration($service_name)

=cut

sub configuration
{
    my $service_name = shift;

    my $conf = OneTool::LogManagement::Configuration::get('services', 
		$service_name);

    return ($conf);
}

=head2 list()

=cut

sub list
{
    my @items = OneTool::LogManagement::Configuration::items('services');

    return (@items);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
