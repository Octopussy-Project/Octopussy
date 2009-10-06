=head1 NAME

Octopussy::Location - Octopussy Location module

=cut
package Octopussy::Location;

use strict;
use Readonly;
use Octopussy;

Readonly my $FILE_LOCATIONS => "locations";
Readonly my $XML_ROOT => "octopussy_locations";

=head1 FUNCTIONS

=head2 Cities()

Returns Location Cities List

=cut	
sub Cities()
{
	my $conf = AAT::XML::Read(Octopussy::File($FILE_LOCATIONS));
 	my @list = ();

 	foreach my $c (AAT::ARRAY($conf->{city}))
 		{ push(@list, $c->{c_name}); }

	return (sort @list);
}

=head2 City_Add($city)

Add City '$city' to Locations

=cut
sub City_Add($)
{
	my $city = shift;

	return ()	if ((!defined $city) || ($city eq ""));
	my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
	my $exists = 0;
	foreach my $c (Cities())
	  { $exists = 1	if ($c eq $city); }
	if (!$exists)
	{
		push(@{$conf->{city}}, { c_name => $city });
		AAT::XML::Write($file, $conf, $XML_ROOT);
		return ($city);
	}
	return (undef);
}

=head2 City_Remove($city)

Removes City '$city' from Locations

=cut 
sub City_Remove($)
{
	my $city = shift;
	my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
	my @cities = ();

	foreach my $c (AAT::ARRAY($conf->{city}))
  	{ push(@cities, $c)	if ($c->{c_name} ne $city); }
	$conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
}

=head2 Buildings($city)

Returns Buildings List

=cut 
sub Buildings($)
{
	my $city = shift;
 	my $conf = AAT::XML::Read(Octopussy::File($FILE_LOCATIONS));
 	my @list = ();
	my @cities = Cities();
	$city ||= $cities[0];

	foreach my $c (AAT::ARRAY($conf->{city}))
  {
		if ($c->{c_name} eq $city)
		{
			foreach my $b (AAT::ARRAY($c->{building}))
  			{ push(@list, $b->{b_name}); }
		}
  }

	return (sort @list);
}

=head2 Building_Add

Adds Building '$building' to City '$city' Location

=cut
sub Building_Add($$)
{
	my ($city, $building) = @_;

	return () if ((!defined $building) || ($building eq ""));
	my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
	my @cities = ();
	my $result = undef;

	foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    { 
			my $exists = 0;
			foreach my $b (Buildings($city))
				{ $exists = 1 if ($b eq $building); }
			if (!$exists)
			{
				push(@{$c->{building}}, { b_name => $building });
				$result = $building;
			} 
		}
		push(@cities, $c); 
	}
	
	$conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
	return ($result);
}

=head2 Building_Remove

Removes Building '$building' from City '$city' Location

=cut
sub Building_Remove($$)
{
  my ($city, $building) = @_;
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my @cities = ();
	my @buildings = ();

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
			foreach my $b (AAT::ARRAY($c->{building}))
				{ push(@buildings, $b)	if ($b->{b_name} ne $building); }
			$c->{building} = \@buildings;
		}
		push(@cities, $c)
  }
  $conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
}

=head2 Rooms($city, $building)

Returns Rooms List

=cut
sub Rooms($$)
{
	my ($city, $building) = @_;
  my $conf = AAT::XML::Read(Octopussy::File($FILE_LOCATIONS));
  my @list = ();
	my @cities = Cities();
  $city ||= $cities[0];
	my @buildings = Buildings($city);
	$building ||= $buildings[0];

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
      foreach my $b (AAT::ARRAY($c->{building}))
      {
				if ($b->{b_name} eq $building)
        {
					foreach my $r (AAT::ARRAY($b->{room}))
      			{ push(@list, $r->{r_name}); }
				}
      }
    }
  }

  return (sort @list);
}

=head2 Room_Add($city, $building, $room)

Adds Room '$room' to City '$city' Building '$building' Location

=cut
sub Room_Add($$$)
{
  my ($city, $building, $room) = @_;

	return () if ((!defined $room) || ($room eq ""));
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my @cities = ();
	my @buildings = ();
	my @rooms = ();
	my $result = undef;

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
		{
			foreach my $b (AAT::ARRAY($c->{building}))
			{
				if ($b->{b_name} eq $building)
				{ 
					my $exists = 0;
      		foreach my $r (Rooms($city, $building))
        		{ $exists = 1 if ($r eq $room); }
					if (!$exists)
					{
						push(@{$b->{room}}, { r_name => $room });
						$result = $room;
					} 
				}
				push(@buildings, $b);
			}
			$c->{building} = \@buildings;
		}
		push(@cities, $c);
  }

  $conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
	return ($result);
}

=head2 Room_Remove($city, $building, $room)

Removes Room '$room' from City '$city' Building '$building' Location

=cut 
sub Room_Remove($$$)
{
  my ($city, $building, $room) = @_;
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my @cities = ();
  my @buildings = ();
	my @rooms = ();

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
      foreach my $b (AAT::ARRAY($c->{building}))
      {
        if ($b->{b_name} eq $building)
				{
					foreach my $r (AAT::ARRAY($b->{room}))
      			{ push(@rooms, $r)	if ($r->{r_name} ne $room); }
					$b->{room} = \@rooms;
				}
				push(@buildings, $b);
      }
      $c->{building} = \@buildings;
    }
    push(@cities, $c);
  }
  $conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
}

=head2 Racks($city, $building, $room)

Returns Racks List

=cut
sub Racks($$$)
{
	my ($city, $building, $room) = @_;
  my $conf = AAT::XML::Read(Octopussy::File($FILE_LOCATIONS));
  my @list = ();
	my @cities = Cities();
  $city ||= $cities[0];
  my @buildings = Buildings($city);
  $building ||= $buildings[0];
	my @rooms = Rooms($city, $building);
	$room ||= $rooms[0];

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
      foreach my $b (AAT::ARRAY($c->{building}))
      {
        if ($b->{b_name} eq $building)
        {
          foreach my $r (AAT::ARRAY($b->{room}))
          {
						if ($r->{r_name} eq $room)
						{
							foreach my $rack (AAT::ARRAY($r->{rack}))
          			{ push(@list, $rack->{r_name}); }
						}
          }
        }
      }
    }
  }

  return (sort @list);
}

=head2 Rack_Add($city, $building, $room, $rack)

Adds Rack '$rack' to City '$city' Building '$building' Room '$room' Location

=cut
sub Rack_Add($$$$)
{
  my ($city, $building, $room, $rack) = @_;

	return () if ((!defined $rack) || ($rack eq ""));
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my (@cities, @buildings, @rooms) = ((), (), ());
	my $result = undef;

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
      foreach my $b (AAT::ARRAY($c->{building}))
      {
        if ($b->{b_name} eq $building)
				{
					foreach my $r (AAT::ARRAY($b->{room}))
					{
						if ($r->{r_name} eq $room)
            {
							my $exists = 0;
          		foreach my $ra (Racks($city, $building, $room))
            		{ $exists = 1 if ($ra eq $rack); } 
							if (!$exists)
							{
								push(@{$r->{rack}}, { r_name => $rack });
								$result = $rack;
							} 
						}
        		push(@rooms, $r);
					}
					$b->{room} = \@rooms;
				}
				push(@buildings, $b);
      }
      $c->{building} = \@buildings;
    }
    push(@cities, $c);
  }
  $conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
	return ($result);
}

=head2 Rack_Remove 

Removes Rack '$rack' from City '$city' Building '$building' Room '$room' Location

=cut
sub Rack_Remove($$$$)
{
  my ($city, $building, $room, $rack) = @_;
  my $file = Octopussy::File($FILE_LOCATIONS);
  my $conf = AAT::XML::Read($file);
  my @cities = ();

  foreach my $c (AAT::ARRAY($conf->{city}))
  {
    if ($c->{c_name} eq $city)
    {
			my @buildings = ();
      foreach my $b (AAT::ARRAY($c->{building}))
      {
        if ($b->{b_name} eq $building)
        {
					my @rooms = ();
          foreach my $r (AAT::ARRAY($b->{room}))
          {
						if ($r->{r_name} eq $room)
						{
							my @racks = ();
							foreach my $rck (AAT::ARRAY($r->{rack}))
								{ push(@racks, $rck)	if ($rck->{r_name} ne $rack); }
							$r->{rack} = \@racks;
						}
						push(@rooms, $r);
          }
          $b->{room} = \@rooms;
        }
        push(@buildings, $b);
      }
      $c->{building} = \@buildings;
    }
    push(@cities, $c);
  }
  $conf->{city} = \@cities;
	AAT::XML::Write($file, $conf, $XML_ROOT);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
