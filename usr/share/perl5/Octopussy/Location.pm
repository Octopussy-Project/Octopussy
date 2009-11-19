# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Location - Octopussy Location module

=cut

package Octopussy::Location;

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(apply none);

use Octopussy;

Readonly my $FILE_LOCATIONS => 'locations';
Readonly my $XML_ROOT       => 'octopussy_locations';

=head1 FUNCTIONS

=head2 Cities()

Returns Location Cities List

=cut	

sub Cities
{
  my $conf = AAT::XML::Read( Octopussy::File($FILE_LOCATIONS) );
  my @list = apply { $_ = $_->{c_name}; } AAT::ARRAY( $conf->{city} );

  return ( sort @list );
}

=head2 City_Add($city)

Add City '$city' to Locations

=cut

sub City_Add
{
  my $city = shift;

  return () if ( ( !defined $city ) || ( $city eq '' ) );
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);

  if ( none { $_ eq $city } Cities() )
  {
    push @{ $conf->{city} }, { c_name => $city };
    AAT::XML::Write( $file, $conf, $XML_ROOT );
    return ($city);
  }

  return (undef);
}

=head2 City_Remove($city)

Removes City '$city' from Locations

=cut 

sub City_Remove
{
  my $city   = shift;
  my $file   = Octopussy::File($FILE_LOCATIONS);
  my $conf   = AAT::XML::Read($file);
  my @cities = grep { $_->{c_name} ne $city } AAT::ARRAY( $conf->{city} );

  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return ( scalar @cities );
}

=head2 Buildings($city)

Returns Buildings List

=cut 

sub Buildings
{
  my $city   = shift;
  my $conf   = AAT::XML::Read( Octopussy::File($FILE_LOCATIONS) );
  my @list   = ();
  my @cities = Cities();
  $city ||= $cities[0];

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      @list = apply { $_ = $_->{b_name}; } AAT::ARRAY( $c->{building} );
    }
  }

  return ( sort @list );
}

=head2 Building_Add

Adds Building '$building' to City '$city' Location

=cut

sub Building_Add
{
  my ( $city, $building ) = @_;

  return () if ( ( !defined $building ) || ( $building eq '' ) );
  my $file   = Octopussy::File($FILE_LOCATIONS);
  my $conf   = AAT::XML::Read($file);
  my @cities = ();
  my $result = undef;

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      my @buildings = Buildings($city);
      if ( ( !scalar @buildings ) || ( none { $_ eq $building } @buildings ) )
      {
        push @{ $c->{building} }, { b_name => $building };
        $result = $building;
      }
    }
    push @cities, $c;
  }

  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );
  return ($result);
}

=head2 Building_Remove

Removes Building '$building' from City '$city' Location

=cut

sub Building_Remove
{
  my ( $city, $building ) = @_;
  my $file      = Octopussy::File($FILE_LOCATIONS);
  my $conf      = AAT::XML::Read($file);
  my @cities    = ();
  my @buildings = ();

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      @buildings =
        grep { $_->{b_name} ne $building } AAT::ARRAY( $c->{building} );
      $c->{building} = \@buildings;
    }
    push @cities, $c;
  }
  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return ( scalar @buildings );
}

=head2 Rooms($city, $building)

Returns Rooms List

=cut

sub Rooms
{
  my ( $city, $building ) = @_;
  my $conf   = AAT::XML::Read( Octopussy::File($FILE_LOCATIONS) );
  my @list   = ();
  my @cities = Cities();
  $city ||= $cities[0];
  my @buildings = Buildings($city);
  $building ||= $buildings[0];

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          @list = apply { $_ = $_->{r_name}; } AAT::ARRAY( $b->{room} );
        }
      }
    }
  }

  return ( sort @list );
}

=head2 Room_Add($city, $building, $room)

Adds Room '$room' to City '$city' Building '$building' Location

=cut

sub Room_Add
{
  my ( $city, $building, $room ) = @_;

  return () if ( ( !defined $room ) || ( $room eq '' ) );
  my $file      = Octopussy::File($FILE_LOCATIONS);
  my $conf      = AAT::XML::Read($file);
  my @cities    = ();
  my @buildings = ();
  my @rooms     = ();
  my $result    = undef;

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          my @rooms = Rooms( $city, $building );
          if ( ( !scalar @rooms ) || ( none { $_ eq $room } @rooms ) )
          {
            push @{ $b->{room} }, { r_name => $room };
            $result = $room;
          }
        }
        push @buildings, $b;
      }
      $c->{building} = \@buildings;
    }
    push @cities, $c;
  }

  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );
  return ($result);
}

=head2 Room_Remove($city, $building, $room)

Removes Room '$room' from City '$city' Building '$building' Location

=cut 

sub Room_Remove
{
  my ( $city, $building, $room ) = @_;
  my $file      = Octopussy::File($FILE_LOCATIONS);
  my $conf      = AAT::XML::Read($file);
  my @cities    = ();
  my @buildings = ();
  my @rooms     = ();

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          @rooms = grep { $_->{r_name} ne $room } AAT::ARRAY( $b->{room} );
          $b->{room} = \@rooms;
        }
        push @buildings, $b;
      }
      $c->{building} = \@buildings;
    }
    push @cities, $c;
  }
  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return ( scalar @rooms );
}

=head2 Racks($city, $building, $room)

Returns Racks List

=cut

sub Racks
{
  my ( $city, $building, $room ) = @_;
  my $conf   = AAT::XML::Read( Octopussy::File($FILE_LOCATIONS) );
  my @list   = ();
  my @cities = Cities();
  $city ||= $cities[0];
  my @buildings = Buildings($city);
  $building ||= $buildings[0];
  my @rooms = Rooms( $city, $building );
  $room ||= $rooms[0];

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          foreach my $r ( AAT::ARRAY( $b->{room} ) )
          {
            if ( $r->{r_name} eq $room )
            {
              @list = apply { $_ = $_->{r_name}; } AAT::ARRAY( $r->{rack} );
            }
          }
        }
      }
    }
  }

  return ( sort @list );
}

=head2 Rack_Add($city, $building, $room, $rack)

Adds Rack '$rack' to City '$city' Building '$building' Room '$room' Location

=cut

sub Rack_Add
{
  my ( $city, $building, $room, $rack ) = @_;

  return () if ( ( !defined $rack ) || ( $rack eq '' ) );
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my ( @cities, @buildings, @rooms ) = ( (), (), () );
  my $result = undef;

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          foreach my $r ( AAT::ARRAY( $b->{room} ) )
          {
            if ( $r->{r_name} eq $room )
            {
              my @racks = Racks( $city, $building, $room );
              if ( ( !scalar @racks ) || ( none { $_ eq $rack } @racks ) )
              {
                push @{ $r->{rack} }, { r_name => $rack };
                $result = $rack;
              }
            }
            push @rooms, $r;
          }
          $b->{room} = \@rooms;
        }
        push @buildings, $b;
      }
      $c->{building} = \@buildings;
    }
    push @cities, $c;
  }
  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );
  return ($result);
}

=head2 Rack_Remove 

Removes Rack '$rack' from City '$city' Building '$building' Room '$room' Location

=cut

sub Rack_Remove
{
  my ( $city, $building, $room, $rack ) = @_;
  my $file      = Octopussy::File($FILE_LOCATIONS);
  my $conf      = AAT::XML::Read($file);
  my @cities    = ();
  my @buildings = ();
  my @rooms     = ();
  my @racks     = ();

  foreach my $c ( AAT::ARRAY( $conf->{city} ) )
  {
    if ( $c->{c_name} eq $city )
    {
      foreach my $b ( AAT::ARRAY( $c->{building} ) )
      {
        if ( $b->{b_name} eq $building )
        {
          foreach my $r ( AAT::ARRAY( $b->{room} ) )
          {
            if ( $r->{r_name} eq $room )
            {
              @racks = grep { $_->{r_name} ne $rack } AAT::ARRAY( $r->{rack} );
              $r->{rack} = \@racks;
            }
            push @rooms, $r;
          }
          $b->{room} = \@rooms;
        }
        push @buildings, $b;
      }
      $c->{building} = \@buildings;
    }
    push @cities, $c;
  }
  $conf->{city} = \@cities;
  AAT::XML::Write( $file, $conf, $XML_ROOT );

  return ( scalar @racks );
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
