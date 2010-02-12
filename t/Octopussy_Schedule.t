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

use Test::More tests => 3;

use Octopussy;
use Octopussy::Schedule;

Readonly my $FILE_SCHEDULES => Octopussy::File('schedule');
Readonly my $PREFIX         => 'Octo_TEST_';
Readonly my $SCHED_TITLE    => "${PREFIX}schedule";
Readonly my $SCHED_REPORT   => "${PREFIX}sched_report";

my %conf = (
  title  => $SCHED_TITLE,
  report => $SCHED_REPORT,
);

my @list = Octopussy::Schedule::List();
Octopussy::Schedule::Add(\%conf);
my @list2 = Octopussy::Schedule::List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Schedule::Add()');
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Schedule::List()');

Octopussy::Schedule::Remove($SCHED_TITLE);
my @list3 = Octopussy::Schedule::List();
ok(scalar @list == scalar @list3, 'Octopussy::Schedule::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
