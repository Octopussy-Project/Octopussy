#!/usr/bin/perl

=head1 NAME

Octopussy_Taxonomy.t - Test Suite for Octopussy::Taxonomy

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::Taxonomy;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../t/data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my @taxo_list     = Octopussy::Taxonomy::List();
my @taxo_list_any = Octopussy::Taxonomy::List_And_Any();

ok((scalar @taxo_list) > 0, 'Octopussy::Taxonomy::List()');
ok((scalar @taxo_list_any) == (scalar @taxo_list + 1),
  'Octopussy::Taxonomy::List_And_Any()');

my @unknowns = Octopussy::Taxonomy::Unknowns();
ok(scalar @unknowns == 0, 'Octopussy::Taxonomy::Unknowns()');

@unknowns = Octopussy::Taxonomy::Unknowns('-any-', 'false_taxonomy');
ok(scalar @unknowns == 1, "Octopussy::Taxonomy::Unknowns('-ANY-', 'false_taxonomy')");

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
        'Octopussy::Taxonomy::Valid_Name(' . $param_str .  ") => $is_valid");
}

done_testing(4 + 3 + 4);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
