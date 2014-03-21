#!/usr/bin/perl

=head1 NAME

t/AAT/Application.t - Test Suite for AAT::Application module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

my $APPLICATION         = 'Octopussy';
my $USER                = 'octopussy';
my $DIR_DEVICES         = './t/data/conf/devices/';
my $FILE_STORAGES       = './t/data/conf/storages.xml';
my $PARAMETER_LOGROTATE = 90;

my $info = AAT::Application::Info($APPLICATION);
cmp_ok($info->{user}, 'eq', $USER, 'AAT::Application::Info()');

my $dir_devices = AAT::Application::Directory($APPLICATION, 'devices');
cmp_ok($dir_devices, 'eq', $DIR_DEVICES, 'AAT::Application::Directory()');

my $file_storages = AAT::Application::File($APPLICATION, 'storages');
cmp_ok($file_storages, 'eq', $FILE_STORAGES, 'AAT::Application::File()');

my $parameter_logrotate =
    AAT::Application::Parameter($APPLICATION, 'logrotate');
cmp_ok($parameter_logrotate, 'eq', $PARAMETER_LOGROTATE,
    'AAT::Application::Parameter()');

done_testing(4);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
