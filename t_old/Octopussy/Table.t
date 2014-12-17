#!/usr/bin/perl

=head1 NAME

t/Octopussy/Table.t - Test Suite for Octopussy::Table module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use List::MoreUtils;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use Octopussy::FS;

my $PREFIX            = 'Octo_TEST_';
my $DEFAULT_NB_FIELDS = 2;

my ($table, $table_desc, $table_field) =
    ("${PREFIX}table", "${PREFIX}table_desc", "${PREFIX}table_field");
my $dir = Octopussy::FS::Directory('tables');
Octopussy::FS::Create_Directory($dir);

require_ok('Octopussy::Table');

Octopussy::Table::New({name => $table, description => $table_desc});
ok(-f "${dir}/${table}.xml", 'Octopussy::Table::New()');

my @fields = Octopussy::Table::Fields($table);
cmp_ok(scalar @fields, '==', $DEFAULT_NB_FIELDS, 'Octopussy::Table::Fields()');

Octopussy::Table::Add_Field($table, $table_field, 'DATETIME');
@fields = Octopussy::Table::Fields($table);
cmp_ok(
    scalar @fields,
    '==',
    $DEFAULT_NB_FIELDS + 1,
    'Octopussy::Table::Add_Field()'
);

my @fields_confs0 = Octopussy::Table::Fields_Configurations();
ok(!@fields_confs0, 'Octopussy::Table:Fields_Configurations(with no table)');
my @fields_confs1 = Octopussy::Table::Fields_Configurations($table);
cmp_ok(
    scalar @fields_confs1,
    '==',
    $DEFAULT_NB_FIELDS + 1,
    'Octopussy::Table:Fields_Configurations($table)'
);
my @fields_confs2 = Octopussy::Table::Fields_Configurations($table, 'invalid');
cmp_ok(
    scalar @fields_confs2,
    '==',
    $DEFAULT_NB_FIELDS + 1,
    'Octopussy::Table:Fields_Configurations($table, invalid_field_sort)'
);

Octopussy::Table::Remove_Field($table, $table_field);
@fields = Octopussy::Table::Fields($table);
cmp_ok(scalar @fields,
    '==', $DEFAULT_NB_FIELDS, 'Octopussy::Table::Remove_Field()');

@fields = Octopussy::Table::Field_Type_List($table, 'datetime');
cmp_ok(scalar @fields, '==', 1, 'Octopussy::Table::Field_Type_List()');

my $sql = Octopussy::Table::SQL($table, ['datetime', 'device'], undef);
cmp_ok(
    $sql,
    'eq',
"CREATE TABLE `Octo_TEST_table` (`datetime` DATETIME, `device` VARCHAR(250))",
    'Octopussy::Table::SQL()'
);

Octopussy::Table::Clone($table, $table . '_cloned');
my @tables = Octopussy::Table::List();
cmp_ok(scalar @tables, '==', 2, 'Octopussy::Table::Clone()');

my @confs = Octopussy::Table::Configurations();
ok($confs[0]->{name} eq $table && $confs[1]->{name} eq $table . '_cloned',
    'Octopussy::Table::Configurations()');

Octopussy::Table::Remove($table);
Octopussy::Table::Remove($table . '_cloned');
@tables = Octopussy::Table::List();

#ok((scalar @tables == 1) && (!defined $tables[0]),
#	'Octopussy::Table::Remove()');
cmp_ok(scalar @tables, '==', 0, 'Octopussy::Table::Remove()');

# 3 Tests for invalid table name
foreach my $name (undef, '', 'table with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Table::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Table::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid table name
foreach my $name ('valid-table', 'valid_table')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Table::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Table::Valid_Name(' . $param_str . ") => $is_valid");
}

done_testing(1 + 12 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
