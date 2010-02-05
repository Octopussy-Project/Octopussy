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

use Test::More tests => 2;

use Octopussy::DeviceGroup;

#
# check DeviceGroup.pm (2 tests)
#
Readonly my $PREFIX      => 'Octo_TEST_';
Readonly my $DG_ID       => "${PREFIX}devicegroup";
Readonly my $DG_DESC    => "${PREFIX}devicegroup Description";
Readonly my $DIR_DEVICES => '/var/lib/octopussy/conf/devices/';

my $error1 = Octopussy::DeviceGroup::Add({ dg_id => $DG_ID, 
  description => $DG_DESC, type => "static", 
  device => [ "${PREFIX}device1", "${PREFIX}device2" ] });

my $error2 = Octopussy::DeviceGroup::Add({ dg_id => $DG_ID,
  description => $DG_DESC, type => "static", 
  device => [ "${PREFIX}device1", "${PREFIX}device2" ] });

ok(((!defined $error1) && (defined $error2)), 'Octopussy::DeviceGroup::Add()');

=head2
my $conf = Octopussy::Device::Configuration("${PREFIX}device");
ok($conf->{name} eq "${PREFIX}device", 'Octopussy::Device::Configuration()');

Octopussy::Device::Modify(
  {name => "${PREFIX}device", description => $DEV_DESC});
$conf = Octopussy::Device::Configuration("${PREFIX}device");
ok($conf->{description} eq $DEV_DESC, 'Octopussy::Device::Modify()');
=cut

Octopussy::DeviceGroup::Remove($DG_ID);
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
