#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Storage.t - Octopussy Source Code Checker for Octopussy::Storage

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(none);
use Test::More tests => 5;

use Octopussy::Storage;

Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $FILE_STORAGE      => Octopussy::File('storages');
Readonly my $STORAGE           => "${PREFIX}storage";
Readonly my $STORAGE_PATH      => '/tmp';

# Backup current Configuration
system "mv $FILE_STORAGE ${FILE_STORAGE}.backup";

my %default = ( 
  incoming => $STORAGE, 
  unknown => $STORAGE,
  known => $STORAGE,
  );

my $file = Octopussy::Storage::Default_Set(\%default);
ok(-f $file, 'Octopussy::Storage::Default_Set()');

my $default = Octopussy::Storage::Default();
ok($default->{incoming} eq $STORAGE && $default->{unknown} eq $STORAGE
  && $default->{known} eq $STORAGE, 'Octopussy::Storage::Default()');

my @list1 = Octopussy::Storage::List();
my %conf = (s_id => $STORAGE, directory => $STORAGE_PATH);
Octopussy::Storage::Add(\%conf);
my @list2 = Octopussy::Storage::List();
ok(scalar @list2 == 1, 'Octopussy::Storage::Add()');
ok(scalar @list1 + 1 == scalar @list2, 'Octopussy::Storage::List()');

my $conf2 = Octopussy::Storage::Configuration($STORAGE);
ok($conf2->{directory} eq $STORAGE_PATH, 'Octopussy::Storage::Configuration()');

my $dir = Octopussy::Storage::Directory($STORAGE);
ok($dir eq $STORAGE_PATH, 'Octopussy::Storage::Directory()');

#my $dir_service = Directory_Service($device, $service);
#my $dir_incoming = Directory_Incoming($device);
#my $dir_unknown = Directory_Unknown($device);

Octopussy::Storage::Remove($STORAGE);
my @list3 = Octopussy::Storage::List();
ok(scalar @list1 == scalar @list3, 'Octopussy::Storage::Remove()');

# Restore backuped Configuration
system "mv ${FILE_STORAGE}.backup $FILE_STORAGE";

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
