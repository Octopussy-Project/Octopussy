#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Schedule.t - Octopussy Source Code Checker for Octopussy::Schedule

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 18;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::Schedule;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $FILE_SCHEDULES => Octopussy::FS::File('schedule');
Readonly my $PREFIX         => 'Octo_TEST_';
Readonly my $SCHED_TITLE    => "${PREFIX}schedule";
Readonly my $SCHED_REPORT   => "${PREFIX}sched_report";

my %conf = (
  title  => $SCHED_TITLE,
  report => $SCHED_REPORT,
);

my %dt = (
        year     => '2011',
        month    => '01',
        day      => '07',
        wday     => '1',
        hour     => '18',
        min      => '00'
    );

my @list = Octopussy::Schedule::List();
Octopussy::Schedule::Add(\%conf);
my @list2 = Octopussy::Schedule::List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Schedule::Add()');
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Schedule::List()');

Octopussy::Schedule::Remove($SCHED_TITLE);
my @list3 = Octopussy::Schedule::List();
ok(scalar @list == scalar @list3, 'Octopussy::Schedule::Remove()');

my %sched = ();

%sched = (start_time => undef, dayofweek => undef, dayofmonth => undef, month => undef);    
my $match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(!$match, "Octopussy::Schedule::Match('everything undef' shouldnt match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => undef, dayofmonth => undef, month => undef);    
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Only 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Every Day'], dayofmonth => undef, month => undef );    
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Every Day @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Every Day'], dayofmonth => undef, month => ['Every Month'] );    
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Every Day / Every Month @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Every Day'], dayofmonth => ['07'], month => undef );    
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Every Day the 7th @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Every Day'], dayofmonth => ['07'], month => ['Every Month'] );    
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Every Day / Every Month @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Monday'], dayofmonth => undef, month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Monday / Every Month @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Monday'], dayofmonth => ['07'], month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Monday the 7th / Every Month @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => undef, dayofmonth => undef, month => ['January'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('January @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Monday'], dayofmonth => undef, month => ['January'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('Monday / January @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => undef, dayofmonth => ['07'], month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok($match, "Octopussy::Schedule::Match('the 7th / Every Month @ 18:00' should match 'Monday 201101071800')");

%sched = (start_time => '17:00', dayofweek => ['Every Day'], dayofmonth => undef, month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(! $match, "Octopussy::Schedule::Match('Every Day / Every Month @ 17:00' shouldn't match 'Monday 201101071800')");

%sched = (start_time => '17:00', dayofweek => undef, dayofmonth => undef, month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(! $match, "Octopussy::Schedule::Match('Every Month @ 17:00' shouldn't match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Tuesday'], dayofmonth => undef, month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(! $match, "Octopussy::Schedule::Match('Tuesday 17 / Every Month @ 18:00' shouldn't match 'Monday 201101071800')");

%sched = (start_time => '18:00', dayofweek => ['Monday'], dayofmonth => ['08'], month => ['Every Month'] );
$match = Octopussy::Schedule::Match(\%sched, \%dt);
ok(! $match, "Octopussy::Schedule::Match('Tuesday / Every Month @ 18:00' shouldn't match 'Monday 201101071800')");

unlink $FILE_SCHEDULES;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
