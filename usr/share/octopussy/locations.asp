<WebUI:PageTop title="Locations" help="locations" />
<%
my $f = $Request->Form();
my $city = $f->{city} || $Request->QueryString("city");
my $building = $f->{building} || $Request->QueryString("building");
my $room = $f->{room} || $Request->QueryString("room");
my $rack = $f->{rack} || $Request->QueryString("rack");
my $action = $Request->QueryString("action");

if ((defined $action) && ($action eq "remove"))
{
	if (defined $city)
  {
    if (!defined $building)
   	{ 
			Octopussy::Location::City_Remove($city); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Location City", $city);
		}
    elsif (!defined $room)
   	{ 
			Octopussy::Location::Building_Remove($city, $building); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", 
				"Location Building", "$city - $building");
		}
    elsif (!defined $rack)
    { 
			Octopussy::Location::Room_Remove($city, $building, $room); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", 
				"Location Room", "$city - $building - $room");
		}
    else
    { 
			Octopussy::Location::Rack_Remove($city, $building, $room, $rack); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", 
				"Location Rack", "$city - $building - $room - $rack");
		}
    $Response->Redirect("./locations.asp");
  }
}
else
{
	if (defined $city)
	{
		if (!defined $building)
		{	
			Octopussy::Location::City_Add($city); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Location City", $city);
		}
		elsif (!defined $room)
		{ 
			Octopussy::Location::Building_Add($city, $building); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", 
				"Location Building", "$city - $building");
		}
		elsif (!defined $rack)
		{ 
			Octopussy::Location::Room_Add($city, $building, $room); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", 
				"Location Room", "$city - $building - $room");
		}
		else
		{ 
			Octopussy::Location::Rack_Add($city, $building, $room, $rack); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", 
				"Location Rack", "$city - $building - $room - $rack");
		}
		$Response->Redirect("./locations.asp");
	}
}
%>
<AAT:Inc file="octo_locations_list" url="./locations.asp" />
<WebUI:PageBottom />
