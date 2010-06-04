#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Table.t - Octopussy Source Code Checker for Octopussy::Table

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(none);
use Test::More tests => 6;

use Octopussy::FS;
use Octopussy::Table;

Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $DEFAULT_NB_FIELDS => 2;

my ($table, $table_desc, $table_field) =
  ("${PREFIX}table", "${PREFIX}table_desc", "${PREFIX}table_field");
my $dir = Octopussy::FS::Directory('tables');

Octopussy::Table::New({name => $table, description => $table_desc});
ok(-f "${dir}/${table}.xml", 'Octopussy::Table::New()');

my @fields = Octopussy::Table::Fields($table);
ok(scalar @fields == $DEFAULT_NB_FIELDS, 'Octopussy::Table::Fields()');

Octopussy::Table::Add_Field($table, $table_field, 'DATETIME');
@fields = Octopussy::Table::Fields($table);
ok(scalar @fields == $DEFAULT_NB_FIELDS + 1, 'Octopussy::Table::Add_Field()');

Octopussy::Table::Remove_Field($table, $table_field);
@fields = Octopussy::Table::Fields($table);
ok(scalar @fields == $DEFAULT_NB_FIELDS, 'Octopussy::Table::Remove_Field()');

@fields = Octopussy::Table::Field_Type_List($table, "datetime");
ok(scalar @fields == 1, 'Octopussy::Table::Field_Type_List()');

Octopussy::Table::Remove($table);
my @tables = Octopussy::Table::List();
ok((none { $_ eq $table } @tables), 'Octopussy::Table::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
