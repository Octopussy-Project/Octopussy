#!/usr/bin/perl

=head1 NAME

Octopussy.t - Test Suite for Octopussy module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/data/etc/aat/aat.xml");

my $PREFIX = 'Octo_Test_';

require_ok('Octopussy');

my $version = Octopussy::Version();
ok(defined $version, "Octopussy::Version() returned something");

ok(defined $version && $version =~ /^\d+\.\d+.*$/,
    "Octopussy::Version() returns a version");

my $sf_version = Octopussy::Sourceforge_Version();
ok(
    defined $sf_version && $sf_version =~ /^\d+\.\d+.*$/,
    "Octopussy::Sourceforge_Version() returns a version"
  );

ok(Octopussy::Parameter('logrotate') =~ /^\d+$/, 'Octopussy::Parameter()');

my $ts_version = Octopussy::Timestamp_Version();
like($ts_version, qr/^\d{12}$/,
    "Octopussy::Timestamp_Version() returns timestamped version");

done_testing(1 + 5);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
