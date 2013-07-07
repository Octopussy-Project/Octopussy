#!/usr/bin/perl

=head1 NAME

t/Octopussy/Configuration.t - Test Suite for Octopussy::Configuration module

=cut

use strict;
use warnings;

use File::Basename;
use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::Configuration;
use Octopussy::FS;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);
my $dir_main = Octopussy::FS::Directory('main');
Octopussy::FS::Create_Directory("$dir_main/contacts/");

Readonly my $DIR_BACKUP_TEST => "$FindBin::Bin/../data/etc/octopussy/";
Readonly my $FILE_TEST => "${dir_main}contacts/test.xml";

my $dir_backup = Octopussy::Configuration::Set_Backup_Directory($DIR_BACKUP_TEST);
is($dir_backup, $DIR_BACKUP_TEST, 
	"Octopussy::Configuration::Set_Backup_Directory('$DIR_BACKUP_TEST')");

my @list = Octopussy::Configuration::Backup_List();

# Creates one file to be backuped
system qq{echo "test" > $FILE_TEST};

my $file = Octopussy::Configuration::Backup();
ok(NOT_NULL($file) && -f $file, 
	"Octopussy::Configuration::Backup() => $file");

# Removes the file which should be restored
unlink $FILE_TEST;

my @list2 = Octopussy::Configuration::Backup_List();
cmp_ok(scalar @list + 1, '==', scalar @list2,
  'Octopussy::Configuration::Backup_List()');

my $restore = basename($file);
$restore =~ s/\.tgz$//;

Octopussy::Configuration::Restore($restore);
ok(-f $FILE_TEST, "Octopussy::Configuration::Restore($restore)");

# Removes test file & backup
unlink $FILE_TEST;
unlink $file;

done_testing(4);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
