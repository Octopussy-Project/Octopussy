#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Cache.t - Octopussy Source Code Checker for Octopussy::Cache

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 8;

use Octopussy::Cache;

Readonly my $PREFIX => 'Octo_TEST_';

my $cache = Octopussy::Cache::Init('octo_commander');
ok(AAT::NOT_NULL($cache), 'Octopussy::Cache::Init(octo_commander)');
$cache = Octopussy::Cache::Init('octo_dispatcher');
ok(AAT::NOT_NULL($cache), 'Octopussy::Cache::Init(octo_dispatcher)');
$cache = Octopussy::Cache::Init('octo_extractor');
ok(AAT::NOT_NULL($cache), 'Octopussy::Cache::Init(octo_extractor)');
$cache = Octopussy::Cache::Init('octo_parser');
ok(AAT::NOT_NULL($cache), 'Octopussy::Cache::Init(octo_parser)');
$cache = Octopussy::Cache::Init('octo_reporter');
ok(AAT::NOT_NULL($cache), 'Octopussy::Cache::Init(octo_reporter)');

my $no_cache = Octopussy::Cache::Init($PREFIX);
ok(AAT::NULL($no_cache), 'Octopussy::Cache::Init() only for some namespaces');

$cache->set("${PREFIX}cache_key", "${PREFIX}cache_value");
my $cache_value = $cache->get("${PREFIX}cache_key");

ok($cache_value eq "${PREFIX}cache_value", '$cache->get / $cache->set');

$cache->remove("${PREFIX}cache_key");
$cache_value = $cache->get("${PREFIX}cache_key");

ok(AAT::NULL($cache_value), '$cache->remove');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
