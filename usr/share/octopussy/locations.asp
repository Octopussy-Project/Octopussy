<WebUI:PageTop title="_LOCATIONS" help="locations" />
<%
my $f = $Request->Form();
my $city = Encode::decode_utf8($f->{city} || $Request->QueryString("city"));
$city = (($city =~ /^[a-z0-9][a-z0-9 '_-]*$/i) ? $city : undef);
my $building = Encode::decode_utf8($f->{building} || $Request->QueryString("building"));
$building = (($building =~ /^[a-z0-9][a-z0-9 '_-]*$/i) ? $building : undef);
my $room = Encode::decode_utf8($f->{room} || $Request->QueryString("room"));
$room = (($room =~ /^[a-z0-9][a-z0-9 '_-]*$/i) ? $room : undef);
my $rack = Encode::decode_utf8($f->{rack} || $Request->QueryString("rack"));
$rack = (($rack =~ /^[a-z0-9][a-z0-9 '_-]*$/i) ? $rack : undef);
my $action = $Request->QueryString("action");

if ((NOT_NULL($action)) && ($action eq "remove"))
{
	if (defined $city)
  {
    if (NULL($building))
   	{ 
			Octopussy::Location::City_Remove($city); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Location City", $city, $Session->{AAT_LOGIN});
		}
    elsif (NULL($room))
   	{ 
			Octopussy::Location::Building_Remove($city, $building); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Location Building", "$city - $building", $Session->{AAT_LOGIN});
		}
    elsif (NULL($rack))
    { 
			Octopussy::Location::Room_Remove($city, $building, $room); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Location Room", "$city - $building - $room", $Session->{AAT_LOGIN});
		}
    else
    { 
			Octopussy::Location::Rack_Remove($city, $building, $room, $rack); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Location Rack", "$city - $building - $room - $rack", $Session->{AAT_LOGIN});
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
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Location City", $city, $Session->{AAT_LOGIN});
		}
		elsif (NULL($room))
		{ 
			Octopussy::Location::Building_Add($city, $building); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Location Building", "$city - $building", $Session->{AAT_LOGIN});
		}
		elsif (NULL($rack))
		{ 
			Octopussy::Location::Room_Add($city, $building, $room); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Location Room", "$city - $building - $room", $Session->{AAT_LOGIN});
		}
		else
		{ 
			Octopussy::Location::Rack_Add($city, $building, $room, $rack); 
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Location Rack", "$city - $building - $room - $rack", $Session->{AAT_LOGIN});
		}
		$Response->Redirect("./locations.asp");
	}
}
%>
<AAT:Inc file="octo_locations_list" url="./locations.asp" />
<WebUI:PageBottom />
