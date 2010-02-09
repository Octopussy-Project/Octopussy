#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Device.t - Octopussy Source Code Checker for Octopussy::Device

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 4;

use Octopussy;
use Octopussy::Device;

Readonly my $DIR_DEVICES => Octopussy::Directory('devices');
Readonly my $PREFIX      => 'Octo_TEST_';
Readonly my $DEV_DESC    => "${PREFIX}device Description";

Octopussy::Device::New({name => "${PREFIX}device", address => '1.2.3.4'});
ok(-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::New()');

my $conf = Octopussy::Device::Configuration("${PREFIX}device");
ok($conf->{name} eq "${PREFIX}device", 'Octopussy::Device::Configuration()');

Octopussy::Device::Modify(
  {name => "${PREFIX}device", description => $DEV_DESC});
$conf = Octopussy::Device::Configuration("${PREFIX}device");
ok($conf->{description} eq $DEV_DESC, 'Octopussy::Device::Modify()');

Octopussy::Device::Remove("${PREFIX}device");
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
