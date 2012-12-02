#!/usr/bin/perl

=head1 NAME

Octopussy.t - Test Suite for Octopussy::FS

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::FS;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my $dir = Octopussy::FS::Directory('main');
ok(NOT_NULL($dir), "Octopussy::FS::Directory('main') => $dir");
my @dirs = Octopussy::FS::Directories('main', 'data_logs');
ok(scalar @dirs == 2, 'Octopussy::FS::Directories()');

my $file = Octopussy::FS::File('db');
ok(NOT_NULL($file), "Octopussy::FS::File('db') => $file");
my @files = Octopussy::FS::Files('db', 'proxy');
ok(scalar @files == 2, 'Octopussy::FS::Files()');

done_testing(4);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
