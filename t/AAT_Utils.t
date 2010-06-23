#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT_Utils.t - Octopussy Source Code Checker for AAT::Utils

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 13;

use AAT::Utils;


my $value_scalar = "item";
my @value_array = ("item1", "item2");
my $value_array_ref = \@value_array;

my %value_hash = ( hkey => 'hvalue' );
my $value_hash_ref = \%value_hash;

# ARRAY
my @array = AAT::Utils::ARRAY($value_scalar);
ok($array[0] eq "item", 'AAT::Utils::ARRAY($scalar)');
@array = AAT::Utils::ARRAY(@value_array);
ok($array[0] eq "item1", 'AAT::Utils::ARRAY(@array)');
@array = AAT::Utils::ARRAY($value_array_ref);
ok($array[0] eq "item1", 'AAT::Utils::ARRAY($array_ref)');

# ARRAY_REF
my $array_ref = AAT::Utils::ARRAY_REF($value_scalar);
ok($array_ref->[0] eq "item", 'AAT::Utils::ARRAY_REF($scalar)');
$array_ref = AAT::Utils::ARRAY_REF(@value_array);
ok($array_ref->[0] eq "item1", 'AAT::Utils::ARRAY_REF(@array)');
$array_ref = AAT::Utils::ARRAY_REF($value_array_ref);
ok($array_ref->[0] eq "item1", 'AAT::Utils::ARRAY_REF($array_ref)');

# HASH
my %hash = AAT::Utils::HASH($value_hash_ref);
ok($hash{hkey} eq 'hvalue', 'AAT::Utils::HASH($hash_ref)');

# HASH_KEYS
my @hash_keys = AAT::Utils::HASH($value_hash_ref);
ok($hash_keys[0] eq 'hkey', 'AAT::Utils::HASH_KEYS($hash_ref)');

# NULL
my $null = AAT::Utils::NULL(undef);
ok($null == 1, 'AAT::Utils::NULL(undef) true');
$null = AAT::Utils::NULL('');
ok($null == 1, 'AAT::Utils::NULL(\'\') true');

# NOT_NULL
my $not_null = AAT::Utils::NOT_NULL(undef);
ok($not_null == 0, 'AAT::Utils::NOT_NULL(undef) false');
$not_null = AAT::Utils::NOT_NULL('');
ok($not_null == 0, 'AAT::Utils::NOT_NULL(\'\') false');

# Now_String
my $now_str = AAT::Utils::Now_String();
ok($now_str =~ m{\d{4}/\d{2}/\d{2} \d{2}:\d{2}}, 'AAT::Utils::Now_String()');

1;


=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut