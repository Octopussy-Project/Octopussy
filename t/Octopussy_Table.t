#!/usr/bin/perl

=head1 NAME

Octopussy_Table.t - Test Suite for Octopussy::Table

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use List::MoreUtils;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::Table;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../t/data/etc/aat/aat.xml";
Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $DEFAULT_NB_FIELDS => 2;

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my ($table, $table_desc, $table_field) =
  ("${PREFIX}table", "${PREFIX}table_desc", "${PREFIX}table_field");
my $dir = Octopussy::FS::Directory('tables');
Octopussy::FS::Create_Directory($dir);

Octopussy::Table::New({name => $table, description => $table_desc});
ok(-f "${dir}/${table}.xml", 'Octopussy::Table::New()');

my @fields = Octopussy::Table::Fields($table);
cmp_ok(scalar @fields, '==', $DEFAULT_NB_FIELDS, 'Octopussy::Table::Fields()');

Octopussy::Table::Add_Field($table, $table_field, 'DATETIME');
@fields = Octopussy::Table::Fields($table);
cmp_ok(scalar @fields, '==', $DEFAULT_NB_FIELDS + 1, 'Octopussy::Table::Add_Field()');

Octopussy::Table::Remove_Field($table, $table_field);
@fields = Octopussy::Table::Fields($table);
cmp_ok(scalar @fields, '==', $DEFAULT_NB_FIELDS, 'Octopussy::Table::Remove_Field()');

@fields = Octopussy::Table::Field_Type_List($table, "datetime");
cmp_ok(scalar @fields, '==', 1, 'Octopussy::Table::Field_Type_List()');

Octopussy::Table::Remove($table);
my @tables = Octopussy::Table::List();
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

rmtree $dir;

done_testing(6 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
