#!/usr/bin/perl

=head1 NAME

t/Octopussy/Configuration.t - Test Suite for Octopussy::Configuration module

=cut

use strict;
use warnings;

use FindBin;
use Path::Tiny;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

my $AAT_CONFIG_file_test = "$FindBin::Bin/../data/etc/aat/aat.xml";
AAT::Application::Set_Config_File($AAT_CONFIG_file_test);

use Octopussy::FS;

my $dir_main = Octopussy::FS::Directory('main');
Octopussy::FS::Create_Directory("$dir_main/contacts/");

my $dir_backup_test = "$FindBin::Bin/../data/etc/octopussy/";
my $file_test       = "${dir_main}contacts/test.xml";

require_ok('Octopussy::Configuration');

my $dir_backup =
    Octopussy::Configuration::Set_Backup_Directory($dir_backup_test);
is($dir_backup, $dir_backup_test,
    "Octopussy::Configuration::Set_Backup_Directory('$dir_backup_test')");

my @list = Octopussy::Configuration::Backup_List();

# Creates one file to be backuped
path($file_test)->spew("test");

my $file = Octopussy::Configuration::Backup();
ok(defined $file && -f $file, "Octopussy::Configuration::Backup() => $file");

# Removes the file which should be restored
path($file_test)->remove;

my @list2 = Octopussy::Configuration::Backup_List();

cmp_ok(
    scalar @list + 1,
    '==',
    scalar @list2,
    'Octopussy::Configuration::Backup_List()'
);

my $restore = path($file)->basename(qr/\.tgz/);

Octopussy::Configuration::Restore($restore);
ok(-f $file_test, "Octopussy::Configuration::Restore('$restore')");

# Removes test file & backup
path($file_test)->remove;
path($file)->remove;

done_testing(1 + 4);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
