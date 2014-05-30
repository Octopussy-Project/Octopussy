#!/usr/bin/perl

=head1 NAME

t/Octopussy/Alert.t - Test Suite for Octopussy::Alert module

=cut

use strict;
use warnings;

use Encode;
use File::Path;
use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

my $AAT_CONFIG_FILE_TEST = "$FindBin::Bin/../data/etc/aat/aat.xml";
AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

use AAT::Utils qw( NOT_NULL );
use Octopussy::FS;

my $PREFIX     = 'Octo_TEST_';
my $DIR_ALERTS = Octopussy::FS::Directory('alerts');

my ($name, $desc, $new_desc) =
    ("${PREFIX}alert", "${PREFIX}alert_desc", "${PREFIX}alert_new_desc");

my %conf = (
    name              => $name,
    description       => $desc,
    level             => 'Warning',
    type              => 'Dynamic',
    loglevel          => 'Warning',
    taxonomy          => 'Auth.Failure',
    timeperiod        => '-ANY-',
    status            => 'Disabled',
    device            => ['device1', 'device2'],
    service           => '-ANY-',                  #['service1', 'service2'],
    regexp_include    => undef,
    regexp_exclude    => undef,
    thresold_time     => 1,
    thresold_duration => 1,
    action            => undef,
    contact           => undef,
    msgsubject =>
        Encode::decode_utf8('msg subject for __alert.name__ with device __device.name__ (__device.type__>__device.model__)'),
    msgbody =>
        Encode::decode_utf8("msg body for __alert.name__ with level __alert.level__ Device located in city '__device.location.city__', building '__device.location.building__', room '__device.location.room__', rack '__device.location.rack__'"),
    action_host    => Encode::decode_utf8("${PREFIX}alert action host"),
    action_service => Encode::decode_utf8("${PREFIX}alert action service"),
    action_body    => Encode::decode_utf8("${PREFIX}alert action body"),
);

require_ok('Octopussy::Alert');

my @list = Octopussy::Alert::List();

my $file = Octopussy::Alert::New(\%conf);
ok(NOT_NULL($file) && -f $file, 'Octopussy::Alert::New()');

$conf{name} = $name . ' &éèçà£µ§';
my $undef_file = Octopussy::Alert::New(\%conf);
ok(!defined $undef_file,
    'Octopussy::Alert::New() accepts only /^[-_a-z0-9]+$/i for name');
$conf{name} = $name;

my @list2 = Octopussy::Alert::List();
cmp_ok(scalar @list + 1, '==', scalar @list2, 'Octopussy::Alert::List()');

my @configs = Octopussy::Alert::Configurations();
cmp_ok(
    scalar @configs,
    '==',
    scalar @list2,
    'Octopussy::Alert::Configurations()'
);

#my @alerts_for_device = Octopussy::Alert::For_Device('device1');
#cmp_ok(scalar @alerts_for_device, "eq", 1, "Octopussy::Alert::For_Device('device1')");
# Return 0 because 'device1' doesn't exist

Octopussy::Device::New(
    {
        name    => 'device1',
        address => '1.2.3.4',
        type    => 'Server',
        model   => 'Linux Debian',
		city	=> 'Paris',
		building => 'Building A',
		room	=> 'A1',
		rack	=> 42,
    }
);

my ($subject, $body) =
    Octopussy::Alert::Message_Building(\%conf, 'device1', undef, undef);

printf "Subject: $subject\nBody: $body\n";

ok(
    ($subject eq "msg subject for $name with device device1 (Server>Linux Debian)")
        && ($body eq "msg body for $name with level Warning Device located in city 'Paris', building 'Building A', room 'A1', rack '42'"),
    'Octopussy::Alert::Message_Building()'
  );

my $old_size = -s $file;
$conf{description} = $new_desc;
Octopussy::Alert::Modify($name, \%conf);
my $new_size = -s $file;
cmp_ok($old_size, '<', $new_size, 'Octopussy::Alert::Modify()');

my $new_conf = Octopussy::Alert::Configuration($name);
ok((($new_conf->{description} eq $new_desc) && ($new_conf->{name} eq $name)),
    'Octopussy::Alert::Configuration()');

Octopussy::Alert::Remove($name);
ok(NOT_NULL($file) && !-f $file, 'Octopussy::Alert::Remove()');

# 3 Tests for invalid alert name
foreach my $name (undef, '', 'alert with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Alert::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Alert::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid alert name
foreach my $name ('valid-alert', 'valid_alert')
{
    my $is_valid = Octopussy::Alert::Valid_Name($name);
    ok($is_valid, "Octopussy::Alert::Valid_Name('$name') => $is_valid");
}

my $is_valid = Octopussy::Alert::Valid_Status_Name(undef);
ok(!$is_valid, 'Octopussy::Alert::Valid_Status_Name(undef)');

$is_valid = Octopussy::Alert::Valid_Status_Name('invalid_status');
ok(!$is_valid, "Octopussy::Alert::Valid_Status_Name('invalid_status')");

$is_valid = Octopussy::Alert::Valid_Status_Name('Opened');
ok($is_valid, "Octopussy::Alert::Valid_Status_Name('Opened')");

my @alert_levels = Octopussy::Alert::Levels();
cmp_ok(scalar @alert_levels, 'eq', 2, 'Octopussy::Alert::Levels()');

# Clean stuff
rmtree $DIR_ALERTS;

done_testing(1 + 8 + 3 + 2 + 3 + 1);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
