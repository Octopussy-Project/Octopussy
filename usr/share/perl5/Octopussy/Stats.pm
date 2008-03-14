#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Stats - Octopussy System Stats module

=cut
package Octopussy::Stats;

use strict;
use Sys::CPU;

use constant EVENTS_FILE	=> "octo_dispatcher.stats";

my $pid_dir = undef;

=head1 FUNCTIONS

=head2 CPU_Info()

Returns the CPU Information

=cut 
sub CPU_Info()
{
	my $cnt = Sys::CPU::cpu_count();
	my $info = ($cnt > 1 ? "$cnt X " : "") . Sys::CPU::cpu_type();
		
	return ($info);	
}

=head2 CPU_Usage()

Returns the CPU Usage (user/system/idle/wait in percent)

=cut
sub CPU_Usage()
{
	my $line = `vmstat 1 2 | tail -1`;

	return ( { user => $1, system => $2, idle => $3, wait => $4 } )	
		if ($line =~ /.+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/);
}

=head2 Load()

Returns System Load

=cut
sub Load()
{
	my $line = `uptime`;

	return ($1)
		if ($line =~ /load average: (\d+\.\d+),/);
}

=head2 Mem_Usage()

Returns the Memory usage in this format: "$used M / $total M ($percent%)"

=cut 
sub Mem_Usage()
{
	my $line = `free | grep Mem:`;

	if ($line =~ /Mem:\s+(\d+)\s+(\d+)\s+\d+/)
	{
		my $total = int($1/1024);
		my $used = int($2/1024);
		return ("No Memory Detected") if ($total == 0);
		my $percent = int($used/$total*100);
	
		return ("$used M / $total M ($percent%)");
	}

	return ();
}

=head2 Swap_Usage()

Returns the Swap usage in this format: "$used M / $total M ($percent%)"

=cut 
sub Swap_Usage()
{
	my $line = `free | grep Swap:`;
	
	if ($line =~ /Swap:\s+(\d+)\s+(\d+)\s+\d+/)
  {
   	my $total = int($1/1024);
   	my $used = int($2/1024);
		return ("No Swap Detected")	if ($total == 0);
   	my $percent = int($used/$total*100);

   	return ("$used M / $total M ($percent%)");
 	}

	return ();
}

=head2 Partition_Logs

=cut
sub Partition_Logs()
{
	my @storages = Octopussy::Storage::Configurations();
	my @result = ();
	my %dir;
	my @lines = `df -k`;
	foreach my $l (@lines)
	{
		$dir{"$2"} = $1	
			if ($l =~ /\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)/);
	}
	foreach my $s (@storages)
	{
		my $d = $s->{directory};
		my $match = 0;
		while (($d =~ /^(.*)\//) && (!$match))
		{
			if (defined $dir{$d})
    	{
				push(@result, 
					{ directory => $s->{s_id}, usage => $dir{$d} });
				$match = 1;
    	}
    	else
    	{
      	$d =~ s/^(.*)\/(.+)*$/$1/g;
				$d = ($d eq "" ? "/" : $d);
				if ($d =~ /^\/$/) 
				{
					push(@result, { directory => $s->{s_id}, usage => $dir{$d} });  
					$match = 1;
    		}
			}
		}
	}

	return (@result);
}

=head2 Events()

Returns Stats Events

=cut 
sub Events()
{
	my %device;

	$pid_dir ||= Octopussy::Directory("running");
	open(FILE, "< $pid_dir/" . EVENTS_FILE);
	my $time;
	while (<FILE>)
	{
		$time = $1	if ($_ =~ /\[(\d+)\]/);
		$device{$1} = $2	if ($_ =~ /^(.+): (\d+)$/);
	}
	close(FILE);

	return ($time, \%device);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
