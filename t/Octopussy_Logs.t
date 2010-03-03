#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Logs.t - Octopussy Source Code Checker for Octopussy::Logs

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 7;

use Octopussy;
use Octopussy::Device;
use Octopussy::Logs;

Readonly my $PREFIX => 'Octo_TEST_';
Readonly my $DEVICE => "${PREFIX}Device";
Readonly my $SERVICE => "${PREFIX}Service";
Readonly my $DIR_LOGS => Octopussy::Directory('data_logs');

my ($d_incoming, $d_unknown) = Octopussy::Logs::Init_Directories($DEVICE);
my $dirs_created = 1 if (-d $d_incoming && -d $d_unknown);
ok($d_incoming =~ /\/$DEVICE\/Incoming\// && $d_unknown =~ /\/$DEVICE\/Unknown\// && $dirs_created,
	'Octopussy::Logs::Init_Directories()');

Octopussy::Logs::Remove_Directories($DEVICE);
ok((!-d $d_incoming && !-d $d_unknown), 'Octopussy::Logs::Remove_Directories()');

my %start = ( year => 2010, month => 1, day => 1, hour => 0, min => 0 );
my %finish = ( year => 2010, month => 1, day => 1, hour => 0, min => 30 );
my $start_num = sprintf("%04d%02d%02d%02d%02d", 
	$start{year}, $start{month}, $start{day}, $start{hour}, $start{min});
my $finish_num = sprintf("%04d%02d%02d%02d%02d", 
	$finish{year}, $finish{month}, $finish{day}, $finish{hour}, $finish{min});

# Generate logs files
system "mkdir -p $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/";
system "touch $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_00h00.log.gz";
system "touch $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_00h01.log.gz";
system "touch $DIR_LOGS/$DEVICE/$SERVICE/2010/01/01/msg_01h00.log.gz";

my @files_ymd = Octopussy::Logs::Files_Year_Month_Day(\%start, \%finish, "$DIR_LOGS/$DEVICE/$SERVICE", '2010');
ok(scalar @files_ymd == 3, 
	'Octopussy::Logs::Files_Year_Month_Day()');

my @files_ymdhm = Octopussy::Logs::Files_Year_Month_Day_Hour_Min("$DIR_LOGS/$DEVICE/$SERVICE",
	$start_num, $finish_num, \@files_ymd);
ok(scalar @files_ymdhm == 2, 'Octopussy::Logs::Files_Year_Month_Day_Hour_Min()');

# Need to create Device/Service
Octopussy::Device::New({name => $DEVICE, address => '1.2.3.4'});
Octopussy::Device::Add_Service($DEVICE, $SERVICE);

my $list_files = Octopussy::Logs::Files([ $DEVICE ], [ $SERVICE ], \%start, \%finish);
ok(scalar @{$list_files} == 2, 'Octopussy::Logs::Files()');

my $avail = Octopussy::Logs::Availability($DEVICE, \%start, \%finish);
ok($avail->{$SERVICE}{'01'}{'01'}{'00'}{'00'} && $avail->{$SERVICE}{'01'}{'01'}{'00'}{'01'}, 
	'Octopussy::Logs::Availability()');

my ($hash_files, $nb_files) = Octopussy::Logs::Minutes_Hash([ $DEVICE ], [ $SERVICE ], \%start, \%finish);
ok($nb_files == 2 && defined $hash_files->{201001010001}, 'Octopussy::Logs::Minutes_Hash()');

# Clean stuff
Octopussy::Device::Remove($DEVICE);
system "rm -rf $DIR_LOGS/$DEVICE/";

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut