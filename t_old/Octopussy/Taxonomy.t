#!/usr/bin/perl

=head1 NAME

t/Octopussy/Taxonomy.t - Test Suite for Octopussy::Taxonomy module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

my $COLOR_AUTH_FAILURE = '#00FFF9';
my $COLOR_HARDWARE     = '#AAAAAF';

require_ok('Octopussy::Taxonomy');

my @taxo_list     = Octopussy::Taxonomy::List();
my @taxo_list_any = Octopussy::Taxonomy::List_And_Any();

cmp_ok(scalar @taxo_list, '>', 0, 'Octopussy::Taxonomy::List()');
cmp_ok(
    scalar @taxo_list_any,
    '==',
    scalar @taxo_list + 1,
    'Octopussy::Taxonomy::List_And_Any()'
);

my %color = Octopussy::Taxonomy::Colors();
ok(
    $color{'Auth.Failure'} eq $COLOR_AUTH_FAILURE
        && $color{'Hardware'} eq $COLOR_HARDWARE,
    'Octopussy::Taxonomy::Colors()'
  );

my @unknowns = Octopussy::Taxonomy::Unknowns();
cmp_ok(scalar @unknowns, '==', 0, 'Octopussy::Taxonomy::Unknowns()');

@unknowns = Octopussy::Taxonomy::Unknowns('-any-', 'false_taxonomy');
cmp_ok(scalar @unknowns,
    '==', 1, "Octopussy::Taxonomy::Unknowns('-ANY-', 'false_taxonomy')");

# 3 Tests for invalid taxonomy name
foreach my $name (undef, '', 'invalid_taxonomy')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Taxonomy::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Taxonomy::Valid_Name(' . $param_str . ") => $is_valid");
}

# 4 Tests for valid taxonomy name
foreach my $name ('Config', 'Hardware', 'Network', 'System')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Taxonomy::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Taxonomy::Valid_Name(' . $param_str . ") => $is_valid");
}

done_testing(1 + 5 + 3 + 4);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
