#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Type.t - Octopussy Source Code Checker for Octopussy::Type

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 10;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use Octopussy::Type;

Readonly my $DT1 => 'Dec 24 23:55:55';
Readonly my $DT2 => 'Mon Dec 24 23:55:55 2000';
Readonly my $DT3 => '2000/12/24 23:55:55';
Readonly my $DT4 => '24/Dec/2000:23:55:55 +0100';

Readonly my $RE_DT_ISO     => '\d{4\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}.\d{2}:\d{2}';
Readonly my $RE_DT_SQL     => '\d{4}-\d\d-\d\d \d\d:\d\d:\d\d';
Readonly my $RE_IP_ADDR    => '\d+\.\d+\.\d+\.\d+';
Readonly my $RE_NUMBER     => '[-+]?\d+';
Readonly my $RE_USER_AGENT => '.+';
Readonly my $RE_WORD       => '\S+';

my @confs   = Octopussy::Type::Configurations();
my $date_ok = 0;
my $time_ok = 0;
foreach my $conf (@confs)
{
  $date_ok = 1
    if (($conf->{type_id} eq 'DATE') && ($conf->{re} eq '\d{4}\/\d{2}\/\d{2}'));
  $time_ok = 1
    if (($conf->{type_id} eq 'TIME') && ($conf->{re} eq '\d{2}:\d{2}:\d{2}'));
}
ok($date_ok && $time_ok, 'Octopussy::Type::Configurations()');

my %color = Octopussy::Type::Colors();
ok(
  defined $color{'NUMBER'}
    && defined $color{'WORD'}
    && defined $color{'STRING'}
    && defined $color{'REGEXP'},
  'Octopussy::Type::Colors()'
);

my @list = Octopussy::Type::List();
ok(scalar @list, 'Octopussy::Type::List()');

# Simple Type

my @simple_list = Octopussy::Type::Simple_List();
ok(scalar @simple_list, 'Octopussy::Type::Simple_List()');

my $type_bytes = Octopussy::Type::Simple_Type('BYTES');
my $type_email = Octopussy::Type::Simple_Type('EMAIL');
ok(
  $type_bytes eq 'NUMBER' && $type_email eq 'STRING',
  'Octopussy::Type::Simple_Type(one_type)'
);

# SQL

my @sql_list = Octopussy::Type::SQL_List();
ok(scalar @sql_list, 'Octopussy::Type::SQL_List()');

my $sqltype_pid   = Octopussy::Type::SQL_Type('PID');
my $sqltype_email = Octopussy::Type::SQL_Type('EMAIL');
ok($sqltype_email eq 'VARCHAR(250)' && $sqltype_pid eq 'BIGINT',
  'Octopussy::Type::SQL_Type(one_type)');

my $sql_dt1 = Octopussy::Type::SQL_Datetime($DT1);
my $sql_dt2 = Octopussy::Type::SQL_Datetime($DT2);
my $sql_dt3 = Octopussy::Type::SQL_Datetime($DT3);
my $sql_dt4 = Octopussy::Type::SQL_Datetime($DT4);
ok(
  $sql_dt1      =~ /^$RE_DT_SQL$/
    && $sql_dt2 =~ /^$RE_DT_SQL$/
    && $sql_dt3 =~ /^$RE_DT_SQL$/
    && $sql_dt4 =~ /^$RE_DT_SQL$/,
  'Octopussy::Type::SQL_Datetime()'
);

# Regexps

my %re = Octopussy::Type::Regexps();
ok(
  $re{'NUMBER'}          eq $RE_NUMBER
    && $re{'BYTES'}      eq $RE_NUMBER
    && $re{'WORD'}       eq $RE_WORD
    && $re{'USER_AGENT'} eq $RE_USER_AGENT,
  'Octopussy::Type::Regexps'
);

my $re_dt_iso = Octopussy::Type::Regexp('DATE_TIME_ISO');
my $re_ip_addr   = Octopussy::Type::Regexp('IP_ADDR');
ok($re_dt_iso eq $RE_DT_ISO && $re_ip_addr eq $RE_IP_ADDR,
  'Octopussy::Type::Regexp(one_type)');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
