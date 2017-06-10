#!/usr/bin/perl

=head1 NAME

t/Octopussy/Device.t - Test Suite for Octopussy::Device module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(true);
use Path::Tiny;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use Octopussy;
use Octopussy::FS;

my $DIR_DEVICES = Octopussy::FS::Directory('devices');

my $PREFIX               = 'Octo_TEST_';
my $DEVICE               = "${PREFIX}device";
my $DEV_DESC             = "${PREFIX}device Description";
my @SERVICES             = qw(Octopussy Sshd Linux_Kernel Linux_System);
my $NB_MIN_TYPES         = 10;
my $NB_MIN_SELECT_TYPES  = 5;
my $NB_MIN_MODELS        = 20;
my $NB_MIN_SELECT_MODELS = 14;

require_ok('Octopussy::Device');

path($DIR_DEVICES)->remove_tree({safe => 0});

Octopussy::Device::New(
    {
        name    => "${PREFIX}device",
        address => '1.2.3.4',
        type    => 'Server',
        model   => 'Linux Debian'
    }
);
ok(-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::New()');

my $conf = Octopussy::Device::Configuration($DEVICE);
cmp_ok($conf->{name}, 'eq', $DEVICE, 'Octopussy::Device::Configuration()');

Octopussy::Device::Reload_Required("${PREFIX}device");
$conf = Octopussy::Device::Configuration($DEVICE);
cmp_ok($conf->{reload_required},
    '==', 1, 'Octopussy::Device::Reload_Required()');

my @d_confs_undef = Octopussy::Device::Filtered_Configurations();
cmp_ok(scalar @d_confs_undef,
    '==', 1, 'Octopussy::Device::Filtered_Configurations()');
my @d_confs_any = Octopussy::Device::Filtered_Configurations('-ANY-', '-ANY-');
cmp_ok(scalar @d_confs_any,
    '==', 1, "Octopussy::Device::Filtered_Configurations('-ANY-', '-ANY-')");
my @d_confs1 =
    Octopussy::Device::Filtered_Configurations('Server', 'Linux Debian');
cmp_ok(scalar @d_confs1,
    '==', 1,
    "Octopussy::Device::Filtered_Configurations('Server', 'Linux Debian')");
my @d_confs0 = Octopussy::Device::Filtered_Configurations('Firewall', '-ANY-');
cmp_ok(scalar @d_confs0,
    '==', 0, "Octopussy::Device::Filtered_Configurations(Firewall', '-ANY-')");

my $nb_services = Octopussy::Device::Add_Service('wrong_dev', 'wrong_svc');
ok(!defined $nb_services,
    "Octopussy::Device::Add_Service('wrong_dev', 'wrong_svc') => undef");

$nb_services = 0;
foreach my $s (@SERVICES)
{
    $nb_services = Octopussy::Device::Add_Service($DEVICE, $s);
}
cmp_ok($nb_services, '==', scalar @SERVICES,
    'Octopussy::Device::Add_Service()');

my @services = Octopussy::Device::Services($DEVICE);
cmp_ok(
    scalar @services,
    '==',
    scalar @SERVICES,
    'Octopussy::Device::Services()'
);

my @list_with = Octopussy::Device::With_Service('Octopussy');
ok((grep { /$DEVICE/ } @list_with), 'Octopussy::Device::With_Service()');

$nb_services = Octopussy::Device::Remove_Service('wrong_dev', 'Octopussy');
ok(!defined $nb_services,
    "Octopussy::Device::Remove_Service('wrong_dev, 'wrong_svc')");
$nb_services = Octopussy::Device::Remove_Service($DEVICE, 'Octopussy');
cmp_ok(
    $nb_services, '==',
    scalar @SERVICES - 1,
    'Octopussy::Device::Remove_Service()'
);

#
# 5 tests for Octopussy::Device::Move_Service()
#
my $rank1 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
my $rank2 = Octopussy::Device::Move_Service($DEVICE, 'Linux_Kernel', 'up');
ok(($rank1 eq '01') && !defined $rank2, 'Octopussy::Device::Move_Service(up)');

$rank1 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
$rank2 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'down');
ok(($rank1 eq '03') && !defined $rank2,
    'Octopussy::Device::Move_Service(down)');

$rank1 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'top');
cmp_ok($rank1, 'eq', '01', 'Octopussy::Device::Move_Service(top)');

$rank1 = Octopussy::Device::Move_Service($DEVICE, 'Sshd', 'bottom');
cmp_ok($rank1, 'eq', '03', 'Octopussy::Device::Move_Service(bottom)');

my $modified_name = Octopussy::Device::Modify(
    {name => "modified_$DEVICE", description => $DEV_DESC});
ok(!defined $modified_name,
    'Octopussy::Device::Modify(changed_device_name) => undef');
Octopussy::Device::Modify({name => $DEVICE, description => $DEV_DESC});
Octopussy::Device::Modify(
    {name => "modified_$DEVICE", description => $DEV_DESC});
$conf = Octopussy::Device::Configuration($DEVICE);
cmp_ok($conf->{description}, 'eq', $DEV_DESC, 'Octopussy::Device::Modify()');

my @list = Octopussy::Device::List();
ok((grep { /$DEVICE/ } @list), 'Octopussy::Device::List()');

my $d_str1 = Octopussy::Device::String_List();
my $d_str2 = Octopussy::Device::String_List('any');
ok(
    $d_str1 =~ /^Device list: .*$DEVICE.*$/
        && $d_str2 =~ /^Device list: -ANY-, .*$DEVICE.*$/,
    'Octopussy::Device::String_List'
  );

my $s_str1 = Octopussy::Device::String_Services();
like(
    $s_str1,
    qr/^Service list: -ANY-, $/,
    "Octopussy::Device::String_Services($DEVICE) => $s_str1"
);

my $s_str2 = Octopussy::Device::String_Services($DEVICE);
my $services_list = join(', ', sort grep !/Octopussy/, @SERVICES);
like(
    $s_str2,
    qr/^Service list: -ANY-, $services_list$/,
    "Octopussy::Device::String_Services($DEVICE) => $s_str2"
);

my $s_str3 = Octopussy::Device::String_Services('unknown_device');
like(
    $s_str3,
    qr/^\[ERROR\] Unknown Device\(s\):.+$/,
    "Octopussy::Device::String_Services('unknown_device') => error msg"
);

my @s_confs = Octopussy::Device::Services_Configurations();
cmp_ok(scalar @s_confs, '==', 0,
    'Octopussy::Device::Services_Configurations()');
my @s_confs2 = Octopussy::Device::Services_Configurations($DEVICE);
cmp_ok(scalar @s_confs2,
    '==', 3, "Octopussy::Device::Services_Configurations($DEVICE)");
my @s_confs3 = Octopussy::Device::Services_Configurations($DEVICE, 'bad_sort');
cmp_ok(scalar @s_confs3,
    '==', 3, "Octopussy::Device::Services_Configurations($DEVICE, 'bad_sort')");

Octopussy::Device::Remove($DEVICE);
ok(!-f "${DIR_DEVICES}${PREFIX}device.xml", 'Octopussy::Device::Remove()');

my @unknowns = Octopussy::Device::Unknowns('-ANY-', $DEVICE);
cmp_ok(scalar @unknowns, '==', 1, 'Octopussy::Device::Unknowns()');

my @types = Octopussy::Device::Types();
my $nb_types =
    scalar grep { /^(Desktop PC|Firewall|Router|Server|Switch)$/ } @types;
ok(scalar @types >= $NB_MIN_TYPES && $nb_types == $NB_MIN_SELECT_TYPES,
    'Octopussy::Device::Types()');

my @models = Octopussy::Device::Models('Server');
my $nb_models = true { $_->{name} =~ /^(Linux|Windows).*$/ } @models;
ok(scalar @models >= $NB_MIN_MODELS && $nb_models >= $NB_MIN_SELECT_MODELS,
    'Octopussy::Device::Models()');

my %type = Octopussy::Device::Type_Configurations();
ok(defined $type{Firewall} && defined $type{Router} && defined $type{Server},
    'Octopussy::Device::Type_Configurations()');

#
# 5 tests for Octopussy::Device::Valid_Name() with invalid device names
#
foreach my $name (undef, '', '.invalid_hostname', '-invalid_hostname',
    '^invalid_hostname')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Device::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Device::Valid_Name(' . $param_str . ") => $is_valid");
}

#
# 5 tests for Octopussy::Device::Valid_Name() with valid device names
#
foreach my $name (
    'validhostname', '10.150.1.9',
    '10.150.1.9-1',  'host.domain.com',
    '9_new_valid_hostname_since_rfc1123'
    )
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Device::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Device::Valid_Name(' . $param_str . ") => $is_valid");
}

path($DIR_DEVICES)->remove_tree({safe => 0});

done_testing(1 + 27 + 5 + 5 + 5);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
