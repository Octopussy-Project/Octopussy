#!/usr/bin/perl -w
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

pod.t - Octopussy POD Test

=cut

use strict;
use warnings;

use Test::Pod;
   
my @files = all_pod_files( 'usr/share/perl5/AAT.pm', 'usr/share/perl5/AAT/', 
	'usr/share/perl5/Octopussy.pm', 'usr/share/perl5/Octopussy/'  );
all_pod_files_ok( @files );
    
1;
