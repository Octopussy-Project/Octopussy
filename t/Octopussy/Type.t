#!/usr/bin/perl

=head1 NAME

t/Octopussy/Type.t - Test Suite for Octopussy::Type module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::Type;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";
Readonly my $DT1 => 'Dec 24 23:55:55';
Readonly my $DT2 => 'Mon Dec 24 23:55:55 2000';
Readonly my $DT3 => '2000/12/24 23:55:55';
Readonly my $DT4 => '24/Dec/2000:23:55:55 +0100';
Readonly my $DT5 => '2000-12-24T23:55:55.100000+01:00';

Readonly my $RE_DT_ISO     => '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|(?:.\d{2}:\d{2}))';
Readonly my $RE_DT_SQL     => '\d{4}-\d\d-\d\d \d\d:\d\d:\d\d';
Readonly my $RE_IP_ADDR    => '\d+\.\d+\.\d+\.\d+';
Readonly my $RE_NUMBER     => '[-+]?\d+';
Readonly my $RE_USER_AGENT => '.+';
Readonly my $RE_WORD       => '\S+';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my @confs   = Octopussy::Type::Configurations();
my $date_ok = 0;
my $time_ok = 0;
foreach my $conf (@confs)
{
  $date_ok = 1
    if (($conf->{type_id} eq 'DATE') && ($conf->{re} eq '\d{4}\/\d{2}\/\d{2}'));
  $time_ok = 1
    if (($conf->{type_id} eq 'TIME') && ($conf->{re} eq '\d{1,3}:\d{2}:\d{2}'));
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
cmp_ok($sqltype_pid, 'eq', 'BIGINT', 
	'Octopussy::Type::SQL_Type(PID) => BIGINT');

my $sqltype_email = Octopussy::Type::SQL_Type('EMAIL');
cmp_ok($sqltype_email, 'eq', 'VARCHAR(250)',
	'Octopussy::Type::SQL_Type(EMAIL) => VARCHAR(250)');

my $sqltype_long_string = Octopussy::Type::SQL_Type('LONG_STRING');
cmp_ok($sqltype_long_string, 'eq', 'TEXT', 
    'Octopussy::Type::SQL_Type(LONG_STRING) => TEXT');

my $sqltype_invalid = Octopussy::Type::SQL_Type('INVALID_TYPE');
ok(!defined $sqltype_invalid,        
    'Octopussy::Type::SQL_Type(INVALID_TYPE) => undef');

my $sql_dt1 = Octopussy::Type::SQL_Datetime($DT1);
ok($sql_dt1 =~ /^$RE_DT_SQL$/, 'Octopussy::Type::SQL_Datetime(DT1)');
my $sql_dt2 = Octopussy::Type::SQL_Datetime($DT2);
ok($sql_dt2 =~ /^$RE_DT_SQL$/, 'Octopussy::Type::SQL_Datetime(DT2)');
my $sql_dt3 = Octopussy::Type::SQL_Datetime($DT3);
ok($sql_dt3 =~ /^$RE_DT_SQL$/, 'Octopussy::Type::SQL_Datetime(DT3)');
my $sql_dt4 = Octopussy::Type::SQL_Datetime($DT4);
ok($sql_dt4 =~ /^$RE_DT_SQL$/, 'Octopussy::Type::SQL_Datetime(DT4)');
my $sql_dt5 = Octopussy::Type::SQL_Datetime($DT5);
ok($sql_dt5 =~ /^$RE_DT_SQL$/, 'Octopussy::Type::SQL_Datetime(DT5)');
my $sql_dt_none = Octopussy::Type::SQL_Datetime('no sql datetime');
ok($sql_dt_none eq 'no sql datetime', 
	'Octopussy::Type::SQL_Datetime(no sql datetime) => no sql datetime');

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
cmp_ok($re_dt_iso, 'eq', $RE_DT_ISO,
	"Octopussy::Type::Regexp('DATE_TIME_ISO') => $RE_DT_ISO");
my $re_ip_addr   = Octopussy::Type::Regexp('IP_ADDR');
cmp_ok($re_ip_addr, 'eq', $RE_IP_ADDR,
	"Octopussy::Type::Regexp('IP_ADDR') => $RE_IP_ADDR");
my $re_undef = Octopussy::Type::Regexp('INVALID_TYPE');
ok(!defined $re_undef,
    "Octopussy::Type::Regexp('INVALID_TYPE') => undef");

done_testing(5+1+4+6+1+3);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
