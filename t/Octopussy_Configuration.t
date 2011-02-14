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

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::Configuration;
use Octopussy::FS;


Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);
my $dir_main = Octopussy::FS::Directory('main');
Octopussy::FS::Create_Directory("$dir_main/contacts/");

Readonly my $DIR_BACKUP_TEST => 't/data/etc/octopussy/';
Readonly my $FILE_TEST => "${dir_main}contacts/test.xml";

Octopussy::Configuration::Set_Backup_Directory($DIR_BACKUP_TEST);

my @list = Octopussy::Configuration::Backup_List();

# Creates one file to be backuped
system qq{echo "test" > $FILE_TEST};

my $file = Octopussy::Configuration::Backup();
ok(NOT_NULL($file) && -f $file, 'Octopussy::Configuration::Backup()');

# Removes the file which should be restored
unlink $FILE_TEST;

my @list2 = Octopussy::Configuration::Backup_List();
cmp_ok(scalar @list + 1, '==', scalar @list2,
  'Octopussy::Configuration::Backup_List()');

my $restore = basename($file);
$restore =~ s/\.tgz$//;

Octopussy::Configuration::Restore($restore);
ok(-f $FILE_TEST, 'Octopussy::Configuration::Restore()');

# Removes test file & backup
#unlink $FILE_TEST;
#unlink $file;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
