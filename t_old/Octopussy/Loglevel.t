#!/usr/bin/perl

=head1 NAME

t/Octopussy/Loglevel.t - Test Suite for Octopussy::Loglevel module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

my $AAT_CONFIG_FILE_TEST = "$FindBin::Bin/../data/etc/aat/aat.xml";
AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my $COLOR_DEBUG  = 'gray';
my $NB_LOGLEVELS = 7;

require_ok('Octopussy::Loglevel');

my %color = Octopussy::Loglevel::Colors();
ok(
    (
               ((scalar keys %color) == $NB_LOGLEVELS)
            && ($color{'Debug'} eq $COLOR_DEBUG)
    ),
    'Octopussy::Loglevel::Colors()'
  );

my %level = Octopussy::Loglevel::Levels();
ok((((scalar keys %level) == $NB_LOGLEVELS) && ($level{'Debug'} == 1)),
    'Octopussy::Loglevel::Levels()');

my @unknowns = Octopussy::Loglevel::Unknowns();
cmp_ok(scalar @unknowns, '==', 0, 'Octopussy::Loglevel::Unknowns()');

@unknowns = Octopussy::Loglevel::Unknowns('-ANY-', 'false_loglevel');
cmp_ok(scalar @unknowns,
    '==', 1, "Octopussy::Loglevel::Unknowns('-ANY-', 'false_loglevel')");

# 3 Tests for invalid loglevel name
foreach my $name (undef, '', 'invalid_loglevel')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Loglevel::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Loglevel::Valid_Name(' . $param_str . ") => $is_valid");
}

# 3 Tests for valid loglevel name
foreach my $name ('Debug', 'Information', 'Warning', 'Critical')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Loglevel::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Loglevel::Valid_Name(' . $param_str . ") => $is_valid");
}

done_testing(1 + 4 + 3 + 4);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
