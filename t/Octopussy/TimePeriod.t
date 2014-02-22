#!/usr/bin/perl

=head1 NAME

t/Octopussy/TimePeriod.t - Test Suite for Octopussy::TimePeriod module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::TimePeriod;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $FILE_TIMEPERIOD   => Octopussy::FS::File('timeperiods');
Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $TP_LABEL          => "${PREFIX}timeperiod_label";
Readonly my $TP_RESULT_PERIODS => 'Mon: 08:00-20:00, Tue: 08:00-20:00';

my @dts = ({'Monday' => '08:00-20:00'}, {'Tuesday' => '08:00-20:00'},);

my @list = Octopussy::TimePeriod::List();

my $file = Octopussy::TimePeriod::New({label => $TP_LABEL, dt => \@dts});
my @list2 = Octopussy::TimePeriod::List();

ok(
  $file eq $FILE_TIMEPERIOD
    && scalar @list + 1 == scalar @list2,
  'Octopussy::TimePeriod::New()'
);

ok((any { $_ eq $TP_LABEL } @list2), 'Octopussy::TimePeriod::List()');

my $conf_undef = Octopussy::TimePeriod::Configuration(undef);
ok(!defined $conf_undef,
	'Octopussy::TimePeriod::Configuration(undef) => undef');
my $conf_invalid_name = Octopussy::TimePeriod::Configuration('invalidname');
ok(!defined $conf_invalid_name,
    'Octopussy::TimePeriod::Configuration(invalidname) => undef');

my $conf = Octopussy::TimePeriod::Configuration($TP_LABEL);
ok($conf->{label} eq $TP_LABEL && $conf->{periods} eq $TP_RESULT_PERIODS,
	'Octopussy::TimePeriod::Configuration()');

my @confs = Octopussy::TimePeriod::Configurations();
ok((scalar @confs == 1) && ($confs[0]->{label} eq $TP_LABEL),
	'Octopussy::TimePeriod::Configurations()');

my $match       = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 14:00');
my $dont_match1 = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 21:30');
my $dont_match2 = Octopussy::TimePeriod::Match($TP_LABEL, 'Saturday 14:00');
ok($match && !$dont_match1 && !$dont_match2, 'Octopussy::TimePeriod::Match()');

$file = Octopussy::TimePeriod::Remove($TP_LABEL);
my @list3 = Octopussy::TimePeriod::List();

ok(($file eq $FILE_TIMEPERIOD) &&  (scalar @list == scalar @list3),
	'Octopussy::TimePeriod::Remove()');

# 3 Tests for invalid timeperiod name
foreach my $name (undef, '', 'timeperiod with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

	my $is_valid = Octopussy::TimePeriod::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::TimePeriod::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid timeperiod name
foreach my $name ('valid-timeperiod', 'valid_timeperiod')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

	my $is_valid = Octopussy::TimePeriod::Valid_Name($name);
    ok($is_valid,
        'Octopussy::TimePeriod::Valid_Name(' . $param_str . ") => $is_valid");
}

unlink $FILE_TIMEPERIOD;

done_testing(8 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
