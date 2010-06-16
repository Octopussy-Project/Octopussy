#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT_Application.t - Octopussy Source Code Checker for AAT::Application

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 4;

use AAT::Application;

Readonly my $APPLICATION => 'Octopussy';
Readonly my $USER => 'octopussy';
Readonly my $DIR_DEVICES => '/var/lib/octopussy/conf/devices/';
Readonly my $FILE_STORAGES => '/var/lib/octopussy/conf/storages.xml';
Readonly my $PARAMETER_LOGROTATE => 90;

my $info = AAT::Application::Info($APPLICATION);
ok($info->{user} eq $USER, 'AAT::Application::Info()');

my $dir_devices = AAT::Application::Directory($APPLICATION, 'devices');
ok($dir_devices eq $DIR_DEVICES, 'AAT::Application::Directory()');

my $file_storages = AAT::Application::File($APPLICATION, 'storages');
ok($file_storages eq $FILE_STORAGES, 'AAT::Application::File()');

my $parameter_logrotate = AAT::Application::Parameter($APPLICATION, 'logrotate');
ok($parameter_logrotate eq $PARAMETER_LOGROTATE, 'AAT::Application::Parameter()');

1;


=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut