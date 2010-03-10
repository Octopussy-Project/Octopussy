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

use Test::More tests => 9;

use Octopussy;
use Octopussy::Device;

Readonly my $DIR_DEVICES => Octopussy::Directory('devices');
Readonly my $PREFIX      => 'Octo_TEST_';
Readonly my $DEVICE      => "${PREFIX}device";
Readonly my $DEV_DESC    => "${PREFIX}device Description";
Readonly my @SERVICES => ('Octopussy', 'Sshd', 'Linux_Kernel', 'Linux_System');

Octopussy::Device::New({name => "${PREFIX}device", address => '1.2.3.4'});
ok(-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::New()');

my $conf = Octopussy::Device::Configuration($DEVICE);
ok($conf->{name} eq $DEVICE, 'Octopussy::Device::Configuration()');

my $nb_services = 0;
foreach my $s (@SERVICES)
{
  $nb_services = Octopussy::Device::Add_Service($DEVICE, $s);
}
ok($nb_services == scalar @SERVICES, 'Octopussy::Device::Add_Service()');

my @services = Octopussy::Device::Services($DEVICE);
ok(scalar @services == scalar @SERVICES, 'Octopussy::Device::Services()');

$nb_services = Octopussy::Device::Remove_Service($DEVICE, 'Octopussy');
ok($nb_services == scalar @SERVICES - 1, 'Octopussy::Device::Remove_Service()');

my $rank1 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
my $rank2 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
ok($rank1 eq '01' && !defined $rank2, 'Octopussy::Device::Move_Service(up)');

$rank1 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
$rank2 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
ok($rank1 eq '03' && !defined $rank2, 'Octopussy::Device::Move_Service(down)');

Octopussy::Device::Modify({name => $DEVICE, description => $DEV_DESC});
$conf = Octopussy::Device::Configuration($DEVICE);
ok($conf->{description} eq $DEV_DESC, 'Octopussy::Device::Modify()');

Octopussy::Device::Remove($DEVICE);
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::Remove()');

# TO_DO
# List()
# String_List()
# Filtered_Configurations()
# Services_Configurations()
# With_Service()
# Types()
# Type_Configurations()
# Models()

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
