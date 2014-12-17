#!/usr/bin/perl

=head1 NAME

t/Octopussy/Schedule.t - Test Suite for Octopussy::Schedule module

=cut

use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use Octopussy::FS;

my $FILE_SCHEDULES = Octopussy::FS::File('schedule');
my $PREFIX         = 'Octo_TEST_';
my $SCHED_TITLE    = "${PREFIX}schedule";
my $SCHED_REPORT   = "${PREFIX}sched_report";

my %conf = (
    title  => $SCHED_TITLE,
    report => $SCHED_REPORT,
);

my %dt = (
    year  => '2011',
    month => '01',
    day   => '07',
    wday  => '1',
    hour  => '18',
    min   => '00',
);

require_ok('Octopussy::Schedule');

my @list = Octopussy::Schedule::List();
Octopussy::Schedule::Add(\%conf);
my @list2 = Octopussy::Schedule::List();
cmp_ok(scalar @list + 1, '==', scalar @list2, 'Octopussy::Schedule::Add()');
cmp_ok(scalar @list + 1, '==', scalar @list2, 'Octopussy::Schedule::List()');

Octopussy::Schedule::Remove($SCHED_TITLE);
my @list3 = Octopussy::Schedule::List();
cmp_ok(scalar @list, '==', scalar @list3, 'Octopussy::Schedule::Remove()');

my $period_check =
    Octopussy::Schedule::Period_Check('Day-1', 'Hour-1', 'Day-0', 'Hour-1');
cmp_ok($period_check, '==', 1,
    "Octopussy::Schedule::Period_Check('Day-1', 'Hour-1', 'Day-0', 'Hour-1')");
$period_check =
    Octopussy::Schedule::Period_Check('Day-1', 'Hour-1', 'Day-2', 'Hour-1');
cmp_ok($period_check, '==', 0,
    "Octopussy::Schedule::Period_Check('Day-1', 'Hour-1', 'Day-2', 'Hour-1')");
$period_check =
    Octopussy::Schedule::Period_Check('Day-0', 'Hour-1', 'Day-0', 'Hour-1');
cmp_ok($period_check, '==', 0,
    "Octopussy::Schedule::Period_Check('Day-0', 'Hour-1', 'Day-0', 'Hour-1')");

my %sched = ();

%sched = (
    start_time => undef,
    dayofweek  => undef,
    dayofmonth => undef,
    month      => undef
);
my $match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match,
"Octopussy::Schedule::Match('everything undef' shouldnt match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => undef,
    dayofmonth => undef,
    month      => undef
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Only 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Every Day'],
    dayofmonth => undef,
    month      => undef
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Every Day @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Every Day'],
    dayofmonth => undef,
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Every Day / Every Month @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Every Day'],
    dayofmonth => ['07'],
    month      => undef
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Every Day the 7th @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Every Day'],
    dayofmonth => ['07'],
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Every Day / Every Month @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Monday'],
    dayofmonth => undef,
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Monday / Every Month @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Monday'],
    dayofmonth => ['07'],
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Monday the 7th / Every Month @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => undef,
    dayofmonth => undef,
    month      => ['January']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('January @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Monday'],
    dayofmonth => undef,
    month      => ['January']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('Monday / January @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => undef,
    dayofmonth => ['07'],
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match,
"Octopussy::Schedule::Match('the 7th / Every Month @ 18:00' should match 'Monday 201101071800')"
  );

%sched = (
    start_time => '17:00',
    dayofweek  => ['Every Day'],
    dayofmonth => undef,
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match,
"Octopussy::Schedule::Match('Every Day / Every Month @ 17:00' shouldn't match 'Monday 201101071800')"
  );

%sched = (
    start_time => '17:00',
    dayofweek  => undef,
    dayofmonth => undef,
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match,
"Octopussy::Schedule::Match('Every Month @ 17:00' shouldn't match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Tuesday'],
    dayofmonth => undef,
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match,
"Octopussy::Schedule::Match('Tuesday 17 / Every Month @ 18:00' shouldn't match 'Monday 201101071800')"
  );

%sched = (
    start_time => '18:00',
    dayofweek  => ['Monday'],
    dayofmonth => ['08'],
    month      => ['Every Month']
);
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match,
"Octopussy::Schedule::Match('Tuesday / Every Month @ 18:00' shouldn't match 'Monday 201101071800')"
  );

my $is_valid = Octopussy::Schedule::Valid_Name(undef);
ok(!$is_valid, 'Octopussy::Schedule::Valid_Name(undef)');

$is_valid = Octopussy::Schedule::Valid_Name('schedule with space');
ok(!$is_valid, "Octopussy::Schedule::Valid_Name('schedule with space')");

$is_valid = Octopussy::Schedule::Valid_Name('valid-schedule');
ok($is_valid, "Octopussy::Schedule::Valid_Name('valid-schedule')");

$is_valid = Octopussy::Schedule::Valid_Name('valid_schedule');
ok($is_valid, "Octopussy::Schedule::Valid_Name('valid_schedule')");

unlink $FILE_SCHEDULES;

done_testing(1 + 25);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
