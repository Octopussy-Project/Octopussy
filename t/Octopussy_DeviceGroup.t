#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_DeviceGroup.t - Octopussy Source Code Checker for Octopussy::DeviceGroup

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 6;

use Octopussy::DeviceGroup;

Readonly my $PREFIX      => 'Octo_TEST_';
Readonly my $DG_ID       => "${PREFIX}devicegroup";
Readonly my $DG_DESC     => "${PREFIX}devicegroup Description";
Readonly my $DIR_DEVICES => '/var/lib/octopussy/conf/devices/';

my %conf = (
  dg_id       => $DG_ID,
  description => $DG_DESC,
  type        => 'static',
  device      => ["${PREFIX}device1", "${PREFIX}device2"],
);

my @list1 = Octopussy::DeviceGroup::List();

my $error1 = Octopussy::DeviceGroup::Add(\%conf);
my $error2 = Octopussy::DeviceGroup::Add(\%conf);
ok(((!defined $error1) && (defined $error2)), 'Octopussy::DeviceGroup::Add()');

my $conf = Octopussy::DeviceGroup::Configuration($DG_ID);
ok(
  $conf->{dg_id} eq "${PREFIX}devicegroup",
  'Octopussy::DeviceGroup::Configuration()'
);

my @list2 = Octopussy::DeviceGroup::List();
ok((scalar @list1 == scalar @list2 - 1) && (grep { /$DG_ID/ } @list2),
  'Octopussy::DeviceGroup::List()');

my @devices = Octopussy::DeviceGroup::Devices($DG_ID);
ok(scalar @devices == 2, 'Octopussy::DeviceGroup::Devices()');

my $nb_dgs = Octopussy::DeviceGroup::Remove_Device("${PREFIX}device1");

ok(scalar @devices == 2, 'Octopussy::DeviceGroup::Devices()');

Octopussy::DeviceGroup::Remove($DG_ID);
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::DeviceGroup::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
