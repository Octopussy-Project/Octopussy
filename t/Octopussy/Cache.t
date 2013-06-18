#!/usr/bin/perl

=head1 NAME

t/Octopussy/Cache.t - Test Suite for Octopussy::Cache module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL NULL );
use Octopussy::Cache;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';
Readonly my $PREFIX => 'Octo_TEST_';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my $cache = Octopussy::Cache::Init('octo_commander');
ok(NOT_NULL($cache), 'Octopussy::Cache::Init(octo_commander)');
$cache = Octopussy::Cache::Init('octo_dispatcher');
ok(NOT_NULL($cache), 'Octopussy::Cache::Init(octo_dispatcher)');
$cache = Octopussy::Cache::Init('octo_extractor');
ok(NOT_NULL($cache), 'Octopussy::Cache::Init(octo_extractor)');
$cache = Octopussy::Cache::Init('octo_parser');
ok(NOT_NULL($cache), 'Octopussy::Cache::Init(octo_parser)');
$cache = Octopussy::Cache::Init('octo_reporter');
ok(NOT_NULL($cache), 'Octopussy::Cache::Init(octo_reporter)');

my $no_cache = Octopussy::Cache::Init($PREFIX);
ok(NULL($no_cache), 'Octopussy::Cache::Init() only for some namespaces');

$cache->set("${PREFIX}cache_key", "${PREFIX}cache_value");
my $cache_value = $cache->get("${PREFIX}cache_key");

cmp_ok($cache_value, 'eq', "${PREFIX}cache_value", 'cache->get / cache->set');

$cache->remove("${PREFIX}cache_key");
$cache_value = $cache->get("${PREFIX}cache_key");

ok(NULL($cache_value), 'cache->remove');

my $count_msgid_cleared = Octopussy::Cache::Clear_MsgID_Stats();
ok(defined $count_msgid_cleared, 'Octopussy::Cache::Clear_MsgID_Stats()');
my $count_taxonomy_cleared = Octopussy::Cache::Clear_Taxonomy_Stats();
ok(defined $count_taxonomy_cleared, 'Octopussy::Cache::Clear_Taxonomy_Stats()');

done_testing(8 + 2);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
