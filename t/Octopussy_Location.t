#!/usr/bin/perl

=head1 NAME

Octopussy_Location.t - Test Suite for Octopussy::Location

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Readonly;
use Test::More tests => 12;

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::Location;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $LOCATION_FILE => Octopussy::FS::File('locations');

my ($city, $building, $room, $rack) =
  ('City Test', 'Building Test', 'Room Test', 'Rack Test');

my $city_add1 = Octopussy::Location::City_Add($city);
my $city_add2 = Octopussy::Location::City_Add($city);
ok($city_add1 eq $city && !defined $city_add2,
  'Octopussy::Location::City_Add()');

my $building_add1 = Octopussy::Location::Building_Add($city, $building);
my $building_add2 = Octopussy::Location::Building_Add($city, $building);
ok($building_add1 eq $building && !defined $building_add2,
  'Octopussy::Location::Building_Add()');

my $room_add1 = Octopussy::Location::Room_Add($city, $building, $room);
my $room_add2 = Octopussy::Location::Room_Add($city, $building, $room);
ok($room_add1 eq $room && !defined $room_add2,
  'Octopussy::Location::Room_Add()');

my $rack_add1 = Octopussy::Location::Rack_Add($city, $building, $room, $rack);
my $rack_add2 = Octopussy::Location::Rack_Add($city, $building, $room, $rack);
ok($rack_add1 eq $rack && !defined $rack_add2,
  'Octopussy::Location::Rack_Add()');

my @racks = Octopussy::Location::Racks($city, $building, $room);
ok((any { $_ eq $rack } @racks), 'Octopussy::Location::Racks()');
Octopussy::Location::Rack_Remove($city, $building, $room, $rack);
my @racks2 = Octopussy::Location::Racks($city, $building, $room);
ok(
  (scalar @racks) == (scalar @racks2 + 1),
  'Octopussy::Location::Rack_Remove()'
);

my @rooms = Octopussy::Location::Rooms($city, $building);
ok((any { $_ eq $room } @rooms), 'Octopussy::Location::Rooms()');
Octopussy::Location::Room_Remove($city, $building, $room);
my @rooms2 = Octopussy::Location::Rooms($city, $building);
ok(
  (scalar @rooms) == (scalar @rooms2 + 1),
  'Octopussy::Location::Room_Remove()'
);

my @buildings = Octopussy::Location::Buildings($city);
ok((any { $_ eq $building } @buildings), 'Octopussy::Location::Buildings()');
Octopussy::Location::Building_Remove($city, $building);
my @buildings2 = Octopussy::Location::Buildings($city);
ok(
  (scalar @buildings) == (scalar @buildings2 + 1),
  'Octopussy::Location::Building_Remove()'
);

my @cities = Octopussy::Location::Cities();
ok((any { $_ eq $city } @cities), 'Octopussy::Location::Cities()');
Octopussy::Location::City_Remove($city);
my @cities2 = Octopussy::Location::Cities();
ok(
  (scalar @cities) == (scalar @cities2 + 1),
  'Octopussy::Location::City_Remove()'
);

unlink $LOCATION_FILE;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
