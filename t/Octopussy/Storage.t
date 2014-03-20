#!/usr/bin/perl

=head1 NAME

t/Octopussy/Storage.t - Test Suite for Octopussy::Storage module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(none);
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use Octopussy::FS;

my $PREFIX       = 'Octo_TEST_';
my $FILE_STORAGE = Octopussy::FS::File('storages');
my $STORAGE      = "${PREFIX}storage";
my $STORAGE_PATH = '/tmp';

rename $FILE_STORAGE, "${FILE_STORAGE}.backup";

my %default = (
	incoming => $STORAGE,
  	unknown  => $STORAGE,
  	known    => $STORAGE,
);

require_ok('Octopussy::Storage');

my $file = Octopussy::Storage::Default_Set(\%default);
ok(-f $file, 'Octopussy::Storage::Default_Set()');

my $default = Octopussy::Storage::Default();
ok(
  $default->{incoming}     eq $STORAGE
    && $default->{unknown} eq $STORAGE
    && $default->{known}   eq $STORAGE,
  "Octopussy::Storage::Default() => incoming, unknown, known == $STORAGE"
);

my @list1 = Octopussy::Storage::List();
my %conf = (s_id => $STORAGE, directory => $STORAGE_PATH);
Octopussy::Storage::Add(\%conf);
my @list2 = Octopussy::Storage::List();
cmp_ok(scalar @list2, '==', 1,                 'Octopussy::Storage::Add()');
cmp_ok(scalar @list1 + 1, '==', scalar @list2, 'Octopussy::Storage::List()');

my $conf2 = Octopussy::Storage::Configuration($STORAGE);
cmp_ok($conf2->{directory}, 'eq', $STORAGE_PATH, 'Octopussy::Storage::Configuration()');

my $dir = Octopussy::Storage::Directory($STORAGE);
cmp_ok($dir, 'eq', $STORAGE_PATH, 
	"Octopussy::Storage::Directory('$STORAGE') => $STORAGE_PATH");

foreach my $dev (undef, '', 'DOESNTEXIST')
{
	my $param_str = (defined $dev ? "'$dev'" : 'undef');

	my $dir_incoming = Octopussy::Storage::Directory_Incoming($dev);
	ok(!defined $dir_incoming, 
		'Octopussy::Storage::Directory_Incoming(' . $param_str . ') => undef');

	my $dir_unknown = Octopussy::Storage::Directory_Unknown($dev);
	ok(!defined $dir_unknown,
        'Octopussy::Storage::Directory_Unknown(' . $param_str . ') => undef');

	my $dir_service = Octopussy::Storage::Directory_Service($dev, 'Octopussy');
	ok(!defined $dir_service,
        'Octopussy::Storage::Directory_Service(' . $param_str . ", 'Octopussy') => undef");
}

Octopussy::Storage::Remove($STORAGE);
my @list3 = Octopussy::Storage::List();
cmp_ok(scalar @list1, '==', scalar @list3, 'Octopussy::Storage::Remove()');

# 3 Tests for invalid storage name
foreach my $name (undef, '', 'storage with space')
{
	my $param_str = (defined $name ? "'$name'" : 'undef');

	my $is_valid = Octopussy::Storage::Valid_Name($name);
	ok(!$is_valid, 
		'Octopussy::Storage::Valid_Name(' . $param_str .  ") => $is_valid");
}

# 2 Tests for valid storage name
foreach my $name ('valid-storage', 'valid_storage')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Storage::Valid_Name($name);
    ok($is_valid, 
        'Octopussy::Storage::Valid_Name(' . $param_str .  ") => $is_valid");
}

rename "${FILE_STORAGE}.backup", $FILE_STORAGE;

done_testing(1 + 6 + 3*3 + 1 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
