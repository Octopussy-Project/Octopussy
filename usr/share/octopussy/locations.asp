<WebUI:PageTop title="_LOCATIONS" help="locations" />
<%
my $f = $Request->Form();
my $city = Encode::decode_utf8($f->{city} || $Request->QueryString("city"));
my $building = Encode::decode_utf8($f->{building} || $Request->QueryString("building"));
my $room = Encode::decode_utf8($f->{room} || $Request->QueryString("room"));
my $rack = Encode::decode_utf8($f->{rack} || $Request->QueryString("rack"));
my $action = $Request->QueryString("action");

if ((NOT_NULL($action)) && ($action eq "remove"))
{
	if (defined $city)
  {
    if (NULL($building))
   	{ 
			Octopussy::Location::City_Remove($city); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Location City", $city);
		}
    elsif (NULL($room))
   	{ 
			Octopussy::Location::Building_Remove($city, $building); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", 
				"Location Building", "$city - $building");
		}
    elsif (NULL($rack))
    { 
			Octopussy::Location::Room_Remove($city, $building, $room); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", 
				"Location Room", "$city - $building - $room");
		}
    else
    { 
			Octopussy::Location::Rack_Remove($city, $building, $room, $rack); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", 
				"Location Rack", "$city - $building - $room - $rack");
		}
    $Response->Redirect("./locations.asp");
  }
}
else
{
	if (defined $city)
	{
		if (NULL($building))
		{	
			Octopussy::Location::City_Add($city); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Location City", $city);
		}
		elsif (NULL($room))
		{ 
			Octopussy::Location::Building_Add($city, $building); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", 
				"Location Building", "$city - $building");
		}
		elsif (NULL($rack))
		{ 
			Octopussy::Location::Room_Add($city, $building, $room); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", 
				"Location Room", "$city - $building - $room");
		}
		else
		{ 
			Octopussy::Location::Rack_Add($city, $building, $room, $rack); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", 
				"Location Rack", "$city - $building - $room - $rack");
		}
		$Response->Redirect("./locations.asp");
	}
}
%>
<AAT:Inc file="octo_locations_list" url="./locations.asp" />
<WebUI:PageBottom />
