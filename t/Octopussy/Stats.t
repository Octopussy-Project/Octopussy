#!/usr/bin/perl

=head1 NAME

t/Octopussy/Stats.t - Test Suite for Octopussy::Stats module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use Octopussy::Stats;

my $cpu_info = Octopussy::Stats::CPU_Info();
ok(defined $cpu_info && $cpu_info ne '', 'Octopussy::Stats::CPU_Info()');

my $cpu_usage = Octopussy::Stats::CPU_Usage();
ok(
  defined $cpu_usage
    && $cpu_usage->{user}   =~ /^\d+$/
    && $cpu_usage->{system} =~ /^\d+$/
    && $cpu_usage->{idle}   =~ /^\d+$/
    && $cpu_usage->{wait}   =~ /^\d+$/,
  'Octopussy::Stats::CPU_Usage()'
);

my $load = Octopussy::Stats::Load();
ok(defined $load && $load =~ /^\d+\.\d+$/, 'Octopussy::Stats::Load()');

my $mem_usage = Octopussy::Stats::Mem_Usage();
ok(
  defined $mem_usage && (($mem_usage =~ /\d+ used M \/ \d+ M \(\d+\%\)/)
    || ($mem_usage eq 'No Memory Detected')),
  'Octopussy::Stats::Mem_Usage()'
);

my $swap_usage = Octopussy::Stats::Swap_Usage();
ok(
  defined $swap_usage && (($swap_usage =~ /\d+ used M \/ \d+ M \(\d+\%\)/)
    || ($swap_usage eq 'No Swap Detected')),
  'Octopussy::Stats::Swap_Usage()'
);

my @partitions = Octopussy::Stats::Partition_Logs();
ok(
  scalar @partitions
    && $partitions[0]->{directory} ne ''
    && $partitions[0]->{usage} =~ /^\d+\%$/,
  'Octopussy::Stats::Partition_Logs()'
);

done_testing(6);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
