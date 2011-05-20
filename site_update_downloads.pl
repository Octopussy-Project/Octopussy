#!/usr/bin/perl

use strict;
use warnings;

use Readonly;

use XML::Simple;

Readonly my $SVN_REPO => 'https://syslog-analyzer.svn.sourceforge.net/svnroot/syslog-analyzer';

my $dest_dir = $ARGV[0];
my $svn_dir = "$SVN_REPO/trunk/var/lib/octopussy/conf";

foreach my $conf ('Reports', 'Services', 'Tables')
{
	printf "Updating %s...\n", $conf;
	my $conf_dir = lc $conf;
    `svn co $svn_dir/$conf_dir/ $dest_dir/$conf/`;
    open my $file_idx, '>', "$dest_dir/$conf/_${conf_dir}.idx";
    opendir my $dir, "$dest_dir/$conf/";
    my @files = grep /\.xml$/, readdir $dir;
    foreach my $f (sort @files)
    {
    	#printf("%s - File: %s\n", $conf, "$dest_dir/$conf/$f");
    	my %XML_INPUT_OPTIONS = (KeyAttr => [], ForceArray => 1);
    	my $xml = eval { XMLin("$dest_dir/$conf/$f", %XML_INPUT_OPTIONS); };
    	#printf("XML: name: %s - version: %s\n", $xml->{name}, $xml->{version});
    	print $file_idx "$xml->{name}:$xml->{version}\n";
    }
    close $file_idx;
}