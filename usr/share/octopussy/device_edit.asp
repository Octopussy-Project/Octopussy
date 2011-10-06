<WebUI:PageTop title="Device Edit" help="devices" />
<%
my $f = $Request->Form();
my $device = $f->{device} || $Request->QueryString("device");
my $dtype = $Request->QueryString("device_type");

if ((defined $f->{modify}) && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
{
	my ($city, $building, $room, $rack) = 
    split(/,/, Encode::decode_utf8($f->{"location"}));
	my @async = ();
	push(@async, { regexp => $f->{regexp}, output => $f->{output} } )
		if (ref $f->{regexp} ne "ARRAY");
	my $last_regexp = scalar(@{$f->{regexp}}) - 1;
	for my $i (0..$last_regexp)
	{ 
		push(@async, { regexp => $f->{regexp}[$i], output => $f->{output}[$i] } );
	}
	Octopussy::Device::Modify({ name => $device, 
		logtype => $f->{logtype}, async => \@async, 
		type => $f->{device_type}, model => $f->{device_model}, 
		description =>  Encode::decode_utf8($f->{description}), 
		city => $city, building => $building, room => $room, 
		rack => $rack, logrotate => $f->{logrotate}, 
		minutes_without_logs => $f->{minutes_without_logs} });
	$Response->Redirect("./devices.asp");
}
else
{
	%><AAT:Inc file="octo_device_edition" device="$device" type="$dtype" /><%
}
%>
<WebUI:PageBottom />
