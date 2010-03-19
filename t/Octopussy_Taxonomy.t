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

use Test::More tests => 3;

use Octopussy::Taxonomy;

my @taxo_list     = Octopussy::Taxonomy::List();
my @taxo_list_any = Octopussy::Taxonomy::List_And_Any();

ok((scalar @taxo_list) > 0, 'Octopussy::Taxonomy::List()');
ok((scalar @taxo_list_any) == (scalar @taxo_list + 1),
  'Octopussy::Taxonomy::List_And_Any()');

my @unknowns = Octopussy::Taxonomy::Unknowns('-ANY-', 'false_taxonomy');
ok(scalar @unknowns == 1, 'Octopussy::Taxonomy::Unknowns()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
