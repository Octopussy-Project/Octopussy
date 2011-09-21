#!/usr/bin/perl
=head1 NAME

check_octopussy.pl - Nagios Plugin for Octopussy (www.8pussy.org)

=head1 SYNOPSIS

check_octopussy.pl <options>

  Options:
  -h / --help: prints usage
  --all: check all
  --process: check process (octo_dispatcher, octo_scheduler & syslog-ng)
  --parser: check parsers states
  --partition: check logs partitions

=head1 DESCRIPTION

check_octopussy.pl is the Nagios Plugin to check that Octopussy is working well

=cut

use strict;
use warnings;

use Getopt::Long;

use Octopussy;
use Octopussy::Device;
use Octopussy::Stats;

use constant STATE_OK => 0;
use constant STATE_WARNING => 1;
use constant STATE_CRITICAL => 2;
use constant STATE_UNKNOWN => 3;

my $PROG_NAME = "check_octopussy.pl";
my $VERSION = "0.4";

my $state = STATE_OK;
my $out = undef;

=head1 FUNCTIONS

=head2 Help()

Prints Help about the program

=cut

sub Help()
{
	my $help_str = <<EOF;

  $PROG_NAME ($VERSION)

  Usage: $PROG_NAME <options>

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

Checks that octo_dispatcher,  octo_scheduler & syslog backend are running

=cut

sub Check_Process()
{
	my $localState = STATE_OK;

	my %proc = Octopussy::Process_Status();
	my @processNotRunning = ();
	foreach my $k (sort keys %proc)
	{
		push(@processNotRunning, $k)	if ($proc{$k} == 0);
	}
	$out .= " - " if (defined($out));
	$out .= "Process : ";
	if ($#processNotRunning > -1)
	{
		$localState = STATE_CRITICAL;
		$out .= join(",", sort @processNotRunning) . " not running !";
	}
	else
		{ $out .= "OK"; } 
	$state = ($state < $localState ? $localState : $state);
}

=head2 Check_Parsers_States()

Checks parsers states

=cut

sub Check_Parsers_States()
{
	my $localState = STATE_OK;

	my @dconfs = Octopussy::Device::Configurations();
	my @parserNotRunning = ();
	my %parserWrongNumber = ();
	foreach my $dc (@dconfs)
	{
		my ($name, $status) = ($dc->{name}, $dc->{status});
		my @lines = `ps -edf | egrep "octo_parser $name\$" | grep -v grep`;
		if (($#lines >= 0) && ($status !~ /^Started$/))
		{ # one or more parsers for 'unstarted' device
			$parserWrongNumber{$name} = ($#lines+1)." ($status)";
			$localState = ($localState < STATE_WARNING ? STATE_WARNING : $localState);
		}
		elsif ($#lines > 0)
  		{ # more than one parser for the same device
			$parserWrongNumber{$name} = ($#lines+1)." ($status)";
			$localState = STATE_CRITICAL;
  		}	
		elsif (($#lines == -1) && ($status =~ /^Started$/))
		{ # no parser for a 'started' device
			push(@parserNotRunning, $dc->{name});
		}
	}
	$out .= " - " if (defined($out));
	$out .= "Parser : ";
	if ($#parserNotRunning > -1)
	{
		$localState = STATE_CRITICAL;
		$out .= "No parser for devices : ".join(",", sort @parserNotRunning)." !";
	}
	my @tab = keys(%parserWrongNumber);
	if ( $#tab > -1 )
	{
		my @res = ();
		foreach my $d (sort @tab)
		{
			push(@res, "$d [$parserWrongNumber{$d}]");
		}
		$out .= " ; " if ($#parserNotRunning > -1);
		$out .= "Wrong number of parsers for devices : " . join(",", @res) . " !";
	}
	$out .= "OK" if ($localState == STATE_OK);
	$state = ($state < $localState ? $localState : $state);
}

=head2 Check_Partitions()

Checks partitions space

=cut

sub Check_Partitions()
{
	my $localState = STATE_OK;
	my @storages = Octopussy::Stats::Partition_Logs();
	my %storageError = ();
	foreach my $s (@storages)
	{
		my ($name, $used) = ($s->{directory}, $s->{usage});
		if (($used =~ /9[0-4]\%/) || ($used =~ /8\d\%/))
  		{ # 80%-94%
			$storageError{$name} = $used;
			$localState = ($localState < STATE_WARNING ? STATE_WARNING : $localState);
  		}
		elsif (($used =~ /9[5-9]\%/) || ($used =~ /100\%/))
		{ # 95%-100%
			$storageError{$name} = $used;
			$localState = STATE_CRITICAL;
		}
	}
	$out .= " - " if (defined($out));
	$out .= "Partition : ";
	my @tab = keys(%storageError);
	if ( $#tab > -1 )
	{
		my @res = ();
		foreach my $s (sort @tab)
		{
			push(@res, "$s [$storageError{$s}]");
		}
		$out .= "Over limits : " . join(",", @res) . " !";
	}
	else
		{ $out .= "OK"; }
	$state = ($state < $localState ? $localState : $state);
}

###########################################################

my %option = ();
my $status = GetOptions(\%option, 
	'h', 'help', 
	'all', 
	'process', 
	'parser', 
	'partition'
	);

Help()	if ((! $status) || ($option{h}) || ($option{help}) || 
	((! $option{all}) && (! $option{process}) && (! $option{parser}) && (! $option{partition})));

Check_Process()	if ($option{process} || $option{all});
Check_Parsers_States() if ($option{parser} || $option{all});
Check_Partitions() if ($option{partition} || $option{all});

print "Octopussy $out\n";

exit($state);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
