#!/usr/bin/perl

=head1 NAME

octopussy_api.pl - Octopussy API

=cut

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

require Mojolicious::Commands;
        Mojolicious::Commands->start_app(
            'OneTool::LogManagement::Server::API', 
            'daemon',
            '-l', 'http://*:2000');
            
=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut