#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Taxonomy.t - Octopussy Source Code Checker for Octopussy::Taxonomy

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 6;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::Taxonomy;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my @taxo_list     = Octopussy::Taxonomy::List();
my @taxo_list_any = Octopussy::Taxonomy::List_And_Any();

ok((scalar @taxo_list) > 0, 'Octopussy::Taxonomy::List()');
ok((scalar @taxo_list_any) == (scalar @taxo_list + 1),
  'Octopussy::Taxonomy::List_And_Any()');

my @unknowns = Octopussy::Taxonomy::Unknowns('-ANY-', 'false_taxonomy');
ok(scalar @unknowns == 1, 'Octopussy::Taxonomy::Unknowns()');

my $is_valid = Octopussy::Taxonomy::Valid_Name(undef);
ok(!$is_valid, 'Octopussy::Taxonomy::Valid_Name(undef)');

$is_valid = Octopussy::Taxonomy::Valid_Name('invalid_taxonomy');
ok(!$is_valid, "Octopussy::Taxonomy::Valid_Name('invalid_taxonomy')");

$is_valid = Octopussy::Taxonomy::Valid_Name('System');
ok($is_valid, "Octopussy::Taxonomy::Valid_Name('System')");

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
