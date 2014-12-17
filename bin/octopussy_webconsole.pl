#!/usr/bin/perl
 
use strict;
use warnings;
 
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

# Start command line interface for application
require Mojolicious::Commands;
Mojolicious::Commands->start_app('OneTool::Web');

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut