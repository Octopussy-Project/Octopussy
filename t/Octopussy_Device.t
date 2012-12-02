#!/usr/bin/perl

=head1 NAME

Octopussy_Device.t - Test Suite for Octopussy::Device

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use List::MoreUtils qw(true);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy;
use Octopussy::Device;
use Octopussy::FS;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $DIR_DEVICES  => Octopussy::FS::Directory('devices');
Readonly my $PREFIX       => 'Octo_TEST_';
Readonly my $DEVICE       => "${PREFIX}device";
Readonly my $DEV_DESC     => "${PREFIX}device Description";
Readonly my @SERVICES     => qw(Octopussy Sshd Linux_Kernel Linux_System);
Readonly my $NB_MIN_TYPES => 10;
Readonly my $NB_MIN_SELECT_TYPES  => 5;
Readonly my $NB_MIN_MODELS        => 20;
Readonly my $NB_MIN_SELECT_MODELS => 14;

Octopussy::Device::New({name => "${PREFIX}device", address => '1.2.3.4'});
ok(-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::New()');

my $conf = Octopussy::Device::Configuration($DEVICE);
cmp_ok($conf->{name}, 'eq', $DEVICE, 'Octopussy::Device::Configuration()');

my $nb_services = 0;
foreach my $s (@SERVICES)
{
  $nb_services = Octopussy::Device::Add_Service($DEVICE, $s);
}
cmp_ok($nb_services, '==', scalar @SERVICES, 'Octopussy::Device::Add_Service()');

my @services = Octopussy::Device::Services($DEVICE);
cmp_ok(scalar @services, '==', scalar @SERVICES, 'Octopussy::Device::Services()');

my @list_with = Octopussy::Device::With_Service('Octopussy');
ok((grep { /$DEVICE/ } @list_with), 'Octopussy::Device::With_Service()');

$nb_services = Octopussy::Device::Remove_Service($DEVICE, 'Octopussy');
cmp_ok($nb_services, '==', scalar @SERVICES - 1, 'Octopussy::Device::Remove_Service()');

my $rank1 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
my $rank2 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
ok($rank1 eq '01' && !defined $rank2, 'Octopussy::Device::Move_Service(up)');

$rank1 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
$rank2 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
ok($rank1 eq '03' && !defined $rank2, 'Octopussy::Device::Move_Service(down)');

Octopussy::Device::Modify({name => $DEVICE, description => $DEV_DESC});
$conf = Octopussy::Device::Configuration($DEVICE);
cmp_ok($conf->{description}, 'eq', $DEV_DESC, 'Octopussy::Device::Modify()');

my @list = Octopussy::Device::List();
ok((grep { /$DEVICE/ } @list), 'Octopussy::Device::List()');

my $str1 = Octopussy::Device::String_List();
my $str2 = Octopussy::Device::String_List('any');
ok(
  $str1 =~ /^Device list: .*$DEVICE.*$/
    && $str2 =~ /^Device list: -ANY-, .*$DEVICE.*$/,
  'Octopussy::Device::String_List'
);

Octopussy::Device::Remove($DEVICE);
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::Remove()');

my @unknowns = Octopussy::Device::Unknowns('-ANY-', $DEVICE);
ok(scalar @unknowns == 1, 'Octopussy::Device::Unknowns()');

my @types = Octopussy::Device::Types();
my $nb_types = scalar grep { /^(Desktop PC|Firewall|Router|Server|Switch)$/ }
  @types;    ## no critic
ok(scalar @types >= $NB_MIN_TYPES && $nb_types == $NB_MIN_SELECT_TYPES,
  'Octopussy::Device::Types()');

my @models = Octopussy::Device::Models('Server');
my $nb_models = true { $_->{name} =~ /^(Linux|Windows).*$/ } @models;
ok(scalar @models >= $NB_MIN_MODELS && $nb_models >= $NB_MIN_SELECT_MODELS,
  'Octopussy::Device::Models()');

# 3 Tests for invalid device name
foreach my $name (undef, '', '123invalid_hostname')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Device::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Device::Valid_Name(' . $param_str . ") => $is_valid");
}

# 3 Tests for valid device name
foreach my $name ('validhostname', '10.150.1.9', 'host.domain.com')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Device::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Device::Valid_Name(' . $param_str . ") => $is_valid");
}

# TO_DO
# Filtered_Configurations()
# Services_Configurations()
# Type_Configurations()

rmtree $DIR_DEVICES;

done_testing(15 + 3 + 3);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
