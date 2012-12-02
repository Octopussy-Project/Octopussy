#!/usr/bin/perl

=head1 NAME

AAT_Application.t - Test Suite for AAT::Application

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;

Readonly my $AAT_CONFIG_FILE => "t/data/etc/aat/aat.xml";
Readonly my $APPLICATION => 'Octopussy';
Readonly my $USER => 'octopussy';
Readonly my $DIR_DEVICES => './t/data/conf/devices/';
Readonly my $FILE_STORAGES => './t/data/conf/storages.xml';
Readonly my $PARAMETER_LOGROTATE => 90;

AAT::Application::Set_Config_File($AAT_CONFIG_FILE);

my $info = AAT::Application::Info($APPLICATION);
cmp_ok($info->{user}, 'eq', $USER, 'AAT::Application::Info()');

my $dir_devices = AAT::Application::Directory($APPLICATION, 'devices');
cmp_ok($dir_devices, 'eq', $DIR_DEVICES, 'AAT::Application::Directory()');

my $file_storages = AAT::Application::File($APPLICATION, 'storages');
cmp_ok($file_storages, 'eq', $FILE_STORAGES, 'AAT::Application::File()');

my $parameter_logrotate = AAT::Application::Parameter($APPLICATION, 'logrotate');
cmp_ok($parameter_logrotate, 'eq', $PARAMETER_LOGROTATE, 'AAT::Application::Parameter()');

done_testing(4);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
