#!/usr/bin/perl

=head1 NAME

t/Octopussy/DeviceGroup.t - Test Suite for Octopussy::DeviceGroup module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

my $AAT_CONFIG_FILE_TEST = "$FindBin::Bin/../data/etc/aat/aat.xml";
AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

use Octopussy::FS;

my $PREFIX      = 'Octo_TEST_';
my $DG_FILE     = Octopussy::FS::File('devicegroups');
my $DG_ID       = "${PREFIX}devicegroup";
my $DG_DESC     = "${PREFIX}devicegroup Description";
my $DIR_DEVICES = Octopussy::FS::Directory('devices');

my %conf = (
    dg_id       => $DG_ID,
    description => $DG_DESC,
    type        => 'static',
    device      => ["${PREFIX}device1", "${PREFIX}device2"],
);

require_ok('Octopussy::DeviceGroup');

my @list1 = Octopussy::DeviceGroup::List();

my $error1 = Octopussy::DeviceGroup::Add(\%conf);
my $error2 = Octopussy::DeviceGroup::Add(\%conf);
ok(((!defined $error1) && (defined $error2)), 'Octopussy::DeviceGroup::Add()');

my $conf = Octopussy::DeviceGroup::Configuration($DG_ID);
cmp_ok($conf->{dg_id}, 'eq', "${PREFIX}devicegroup",
    'Octopussy::DeviceGroup::Configuration()');

my @list2 = Octopussy::DeviceGroup::List();
ok((scalar @list1 == scalar @list2 - 1) && (grep { /$DG_ID/ } @list2),
    'Octopussy::DeviceGroup::List()');

my @devices = Octopussy::DeviceGroup::Devices($DG_ID);
cmp_ok(scalar @devices, '==', 2, 'Octopussy::DeviceGroup::Devices()');

my %dg = Octopussy::DeviceGroup::With_Device("${PREFIX}device1");
ok(
    defined $dg{"${PREFIX}devicegroup"},
    "Octopussy::DeviceGroup::With_Device('${PREFIX}device1')"
        . " => '${PREFIX}devicegroup'"
  );

my $nb_dgs = Octopussy::DeviceGroup::Remove_Device("${PREFIX}device1");

cmp_ok(scalar @devices, '==', 2, 'Octopussy::DeviceGroup::Devices()');

Octopussy::DeviceGroup::Remove($DG_ID);
my @list3 = Octopussy::DeviceGroup::List();
ok((scalar @list1 == scalar @list3) && (!grep { /$DG_ID/ } @list3),
    'Octopussy::DeviceGroup::Remove()');

# 3 Tests for invalid devicegroup name
foreach my $name (undef, '', 'devicegroup with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::DeviceGroup::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::DeviceGroup::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid service name
foreach my $name ('devicegroup-name', 'devicegroup.with.dot')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::DeviceGroup::Valid_Name($name);
    ok($is_valid,
        'Octopussy::DeviceGroup::Valid_Name(' . $param_str . ") => $is_valid");
}

unlink $DG_FILE;

done_testing(1 + 4 + 3 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
