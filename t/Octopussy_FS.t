#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy.t - Octopussy Source Code Checker for Octopussy

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 4;

use AAT::Utils qw( NOT_NULL );
use Octopussy::FS;

ok(NOT_NULL(Octopussy::FS::Directory('main')), 'Octopussy::FS::Directory()');
my @dirs = Octopussy::FS::Directories('main', 'data_logs');
ok(scalar @dirs == 2, 'Octopussy::FS::Directories()');

ok(NOT_NULL(Octopussy::FS::File('db')), 'Octopussy::FS::File()');
my @files = Octopussy::FS::Files('db', 'proxy');
ok(scalar @files == 2, 'Octopussy::FS::Files()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut