#!/usr/bin/perl -w

=head1 NAME

check_octopussy.pl - Nagios Plugin for Octopussy

=head1 SYNOPSIS

check_octopussy.pl <options>

=head1 DESCRIPTION

check_octopussy.pl is the Nagios Plugin to check that Octopussy is working well

=cut

use strict;
use Getopt::Long;
Getopt::Long::Configure('bundling');
use Octopussy;

use constant STATE_OK => 0;
use constant STATE_WARNING => 1;
use constant STATE_CRITICAL => 2;
use constant STATE_UNKNOWN => 3;

my ($help, $opt_all, $opt_process, $opt_parser, $opt_partition);
my $state = STATE_OK;

=head1 FUNCTIONS

=head2 Help()

=cut
sub Help()
{
my $help_str = <<EOF;

  Usage: check_octopussy.pl <options>

  Options:
  -h / --help: prints usage
	--all: check all
  --process: check process (octo_dispatcher, octo_scheduler & syslog-ng)
  --parser: check parsers states
  --partition: check logs partitions

EOF

	print $help_str;
	exit(STATE_UNKNOWN);
}

=head2 Check_Process()

Checks that octo_dispatcher,  octo_scheduler & syslog-ng are running

=cut
sub Check_Process()
{
	my %proc = Octopussy::Process_Status();	
	foreach my $k (sort keys %proc)
	{
		if ($proc{$k} == 0)
		{
			print "Process $k is not running !\n";
			$state = STATE_CRITICAL;
		}
	}
}

=head2 Check_Parsers_States()

Checks parsers states

=cut
sub Check_Parsers_States()
{
	my @dconfs = Octopussy::Device::Configurations();
	foreach my $dc (@dconfs)
	{
		my ($name, $status) = ($dc->{name}, $dc->{status});
		my @lines = `ps -edf | egrep "octo_parser $name\$" | grep -v grep`;
		if (($#lines >= 0) && ($status !~ /^Started$/))
		{ # one or more parsers for 'unstarted' device
			print "There is " . ($#lines+1) . " parser(s) for $status device '$name' !\n";
			$state = ($state < STATE_WARNING ? STATE_WARNING : $state);
		}
		elsif ($#lines > 0)
  	{ # more than one parser for the same device
  		print "There is " . ($#lines+1) . " parsers for device '$name' !\n";
    	$state = STATE_CRITICAL;
  	}	
		elsif (($#lines == -1) && ($status =~ /^Started$/))
		{ # no parser for a 'started' device
			print "There is no parser for device '$dc->{name}' !\n";
			$state = STATE_CRITICAL;
		}
	}
}

=head2 Check_Partitions()

Checks partitions space

=cut
sub Check_Partitions()
{
	my @storages = Octopussy::Stats::Partition_Logs();
	foreach my $s (@storages)
	{
		my ($name, $used) = ($s->{directory}, $s->{usage});
		if (($used =~ /9[0-4]\%/) || ($used =~ /8\d\%/))
  	{ # 80%-94%
    	print "Partition $name used space $used !\n";
    	$state = ($state < STATE_WARNING ? STATE_WARNING : $state);
  	}
		elsif (($used =~ /9[5-9]\%/) || ($used =~ /100\%/))
		{ # 95%-100%
			print "Partition $name used space $used !\n";
			$state = STATE_CRITICAL;
		}
	}
}

###########################################################

my $status = GetOptions(
  "h" => \$help, "help" => \$help, "all" => \$opt_all,
	"process" => \$opt_process, "parser" => \$opt_parser, 
	"partition" => \$opt_partition);
Help()	if ((! $status) || ($help));

Check_Process()	if ($opt_process || $opt_all);
Check_Parsers_States() if ($opt_parser || $opt_all);
Check_Partitions() if ($opt_partition || $opt_all);

print "Octopussy is OK !\n"	if ($state == STATE_OK);
exit($state);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
