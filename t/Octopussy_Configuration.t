#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Configuration.t - Octopussy Source Code Checker for Octopussy::Configuration

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 3;

use File::Basename;

use Octopussy::Configuration;

Readonly my $FILE_TEST => '/var/lib/octopussy/conf/contacts/test.test';

my @list = Octopussy::Configuration::Backup_List();

# Creates one file to be backuped
system qq{touch $FILE_TEST};

my $file = Octopussy::Configuration::Backup();
ok(AAT::NOT_NULL($file) && -f $file, 'Octopussy::Configuration::Backup()');

# Removes the file which should be restored
unlink $FILE_TEST;

my @list2 = Octopussy::Configuration::Backup_List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Configuration::Backup_List()'); 

my $restore = basename($file);
$restore =~ s/\.tgz$//;

Octopussy::Configuration::Restore($restore);
ok(-f $FILE_TEST, 'Octopussy::Configuration::Restore()');

# Removes test file & backup
unlink $FILE_TEST;
unlink $file;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
