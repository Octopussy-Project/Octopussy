<WebUI:PageTop title="_LOCATIONS" help="locations" />
<%
my $f = $Request->Form();
my $city = $f->{city} || $Request->QueryString("city");
my $building = $f->{building} || $Request->QueryString("building");
my $room = $f->{room} || $Request->QueryString("room");
my $rack = $f->{rack} || $Request->QueryString("rack");
my $action = $Request->QueryString("action");

if ((AAT::NOT_NULL($action)) && ($action eq "remove"))
{
	if (defined $city)
  {
    if (AAT::NULL($building))
   	{ 
			Octopussy::Location::City_Remove($city); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Location City", $city);
		}
    elsif (AAT::NULL($room))
   	{ 
			Octopussy::Location::Building_Remove($city, $building); 
			AAT::Syslog("octo_WebUI", "GENERIC_DELETED", 
				"Location Building", "$city - $building");
		}
    elsif (AAT::NULL($rack))
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
		if (AAT::NULL($building))
		{	
			Octopussy::Location::City_Add($city); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Location City", $city);
		}
		elsif (AAT::NULL($room))
		{ 
			Octopussy::Location::Building_Add($city, $building); 
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", 
				"Location Building", "$city - $building");
		}
		elsif (AAT::NULL($rack))
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
