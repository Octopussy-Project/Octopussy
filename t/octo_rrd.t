#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

octo_rrd.t - Octopussy Source Code Checker for octo_rrd

=cut

use strict;
use warnings;
use Readonly;

use POSIX qw( mktime );
use Test::More tests => 2;

use Octopussy::Cache;
use Octopussy::RRDTool;
use Octopussy::Taxonomy;

Readonly my $DIR_RRD => '/var/lib/octopussy/rrd';
Readonly my $DEVICE => 'OCTO_TEST_DEVICE';
Readonly my $SERVICE => 'OCTO_TEST_SERVICE';
Readonly my $FILE => "$DIR_RRD/${DEVICE}/taxonomy_${SERVICE}.rrd";

my $cache_parser = Octopussy::Cache::Init('octo_parser');

my $i = 2;
my @taxo_rrd = ();
foreach my $t (Octopussy::Taxonomy::List())
{
	push @taxo_rrd, $i;
	$i += 2;
}

# Clean stuff
system "rm -rf $DIR_RRD/$DEVICE/";

my $seconds_to_parse = mktime(localtime); # '201009011010'
$cache_parser->set("parser_taxo_stats_${DEVICE},${SERVICE}",
	{ datetime => $seconds_to_parse, stats => \@taxo_rrd } );        

Octopussy::RRDTool::Syslog_By_Device_Service_Taxonomy_Init($DEVICE, $SERVICE);
foreach my $k (sort $cache_parser->get_keys())
{
	if ($k =~ /^parser_taxo_stats_(\S+?),(.+)$/)
   	{
    	my $taxo = $cache_parser->get($k);
       	Octopussy::RRDTool::Syslog_By_Device_Service_Taxonomy_Update(
       		$taxo->{datetime}, $1, $2, $taxo->{stats});
      	$cache_parser->remove($k);
      	ok(($1 eq $DEVICE) && ($2 eq $SERVICE), 
      		"Data for Device $DEVICE & Service $SERVICE found in cache.");
   	}
}
ok(-f $FILE, "RRD file $FILE created.");

# Clean stuff
system "rm -rf $DIR_RRD/$DEVICE/";

