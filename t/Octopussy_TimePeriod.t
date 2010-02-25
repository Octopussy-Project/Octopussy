#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_TimePeriod.t - Octopussy Source Code Checker for Octopussy::TimePeriod

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any);
use Test::More tests => 5;

use Octopussy::TimePeriod;

Readonly my $FILE_TIMEPERIOD   => Octopussy::File('timeperiods');
Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $TP_LABEL          => "${PREFIX}timeperiod_label";
Readonly my $TP_RESULT_PERIODS => 'Mon: 08:00-20:00, Tue: 08:00-20:00';

my @dts = ({'Monday' => '08:00-20:00'}, {'Tuesday' => '08:00-20:00'},);

# Backup current configuration
system "cp $FILE_TIMEPERIOD ${FILE_TIMEPERIOD}.backup";

my @list = Octopussy::TimePeriod::List();

my $old_size = -s $FILE_TIMEPERIOD;
my $file = Octopussy::TimePeriod::New({label => $TP_LABEL, dt => \@dts});

my @list2 = Octopussy::TimePeriod::List();

ok(
  $file eq $FILE_TIMEPERIOD
    && -s $file > $old_size
    && scalar @list + 1 == scalar @list2,
  'Octopussy::TimePeriod::New()'
);

ok((any { $_ eq $TP_LABEL } @list2), 'Octopussy::TimePeriod::List()');

my $conf = Octopussy::TimePeriod::Configuration($TP_LABEL);
ok($conf->{label} eq $TP_LABEL && $conf->{periods} eq $TP_RESULT_PERIODS,
  'Octopussy::TimePeriod::Configuration()');

my $match       = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 14:00');
my $dont_match1 = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 21:30');
my $dont_match2 = Octopussy::TimePeriod::Match($TP_LABEL, 'Saturday 14:00');
ok($match && !$dont_match1 && !$dont_match2, 'Octopussy::TimePeriod::Match()');

$file = Octopussy::TimePeriod::Remove($TP_LABEL);
ok($file eq $FILE_TIMEPERIOD && -s $file == $old_size,
  'Octopussy::TimePeriod::Remove()');

# Restore backuped configuration
system "mv ${FILE_TIMEPERIOD}.backup $FILE_TIMEPERIOD";

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
