#!/usr/bin/perl

=head1 NAME

t/AAT/Datetime.t - Test Suite for AAT::Datetime module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;
use Time::Piece;

use lib "$FindBin::Bin/../../lib";

require_ok('AAT::Datetime');

my $nb_days1 = AAT::Datetime::Month_Nb_Days('2014', '01');
cmp_ok($nb_days1, '==', 31, "AAT::Datetime::Month_Nb_Days('2014', '01') => 31");

my $nb_days2 = AAT::Datetime::Month_Nb_Days('2014', '02'); 
cmp_ok($nb_days2, '==', 28, "AAT::Datetime::Month_Nb_Days('2014', '02') => 28");

my $week1 = AAT::Datetime::YearWeek('2013', '12', '25');
cmp_ok($week1, '==', 52, "AAT::Datetime::YearWeek('2013', '12', '25') => 52");

my $week2 = AAT::Datetime::YearWeek('2014', '01', '01');
cmp_ok($week2, '==', 1, "AAT::Datetime::YearWeek('2014', '01', '01') => 1");

my $delta1 = AAT::Datetime::Delta('20140130 23:55:00', '20140131 00:05:00');
cmp_ok($delta1, '==', 10, 
	"AAT::Datetime::Delta('20140130 23:55:00', '20140131 00:05:00') => 10");

my $delta2 = AAT::Datetime::Delta('20140131 00:05:00', '20140130 23:55:00');
cmp_ok($delta2, '==', 10,
	"AAT::Datetime::Delta('20140131 00:05:00', '20140130 23:55:00') => 10");

my ($begin, $end) = AAT::Datetime::Last_Hour();
printf "Last Hour: %s %s\n",
	"$begin->{year}-$begin->{month}-$begin->{day} $begin->{hour} $begin->{min}",
	"$end->{year}-$end->{month}-$end->{day} $end->{hour} $end->{min}";

($begin, $end) = AAT::Datetime::Last_Month();
printf "Last Month: %s %s\n",
    "$begin->{year}-$begin->{month}-$begin->{day} $begin->{hour} $begin->{min}",
    "$end->{year}-$end->{month}-$end->{day} $end->{hour} $end->{min}";

=head2 commen $tp = Time::Piece->new();
my ($begin, $end) = AAT::Datetime::Current_Day();
ok($tp->ymd eq "$begin->{year}-$begin->{month}-$begin->{day}"
	&& $tp->ymd eq "$end->{year}-$end->{month}-$end->{day}"
	&& $begin->{min} eq '00' && $end->{min} eq '59', 
	'AAT::Datetime::Current_Day()');
=cut

done_testing(1 + 2 + 2 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
