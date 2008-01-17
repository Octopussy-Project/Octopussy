<%
my %arg = @_;
my $url = $arg{url};
my $device = $arg{device};
$url .= "?device=$device";
my $url_sort = $url . "&device_services_table_sort=";
my $sort = defined $arg{sort} ? lc($arg{sort}) : "rank";
my $role = $Session->{AAT_ROLE};
my @services = Octopussy::Device::Services($device);
my %stats = Octopussy::Device::Services_Statistics($device);
my $str = sprintf(AAT::Translation("_MSG_SERVICES_FOR_DEVICE"), $device);
my @table = (
	[ { label => $str, size => "+1", align => "C", colspan => 5 } ],
	[ { label => "<hr>", colspan => 5 } ],
  [ { label => "_RANK", link => $url_sort . "rank"  }, 
		{ label => "_SERVICE", link => $url_sort . "sid" },
   	{ label => (($role !~ /ro/i) ? "_ACTION" : ""), 
			colspan => 3, align => "C" } ],
	[ { label => "<hr>", 			colspan => 5 } ]
  );

my $nb_services = 0;
my $total_messages = 0;
foreach my $conf (Octopussy::Device::Services_Configurations($device, $sort))
{
	my @row = ();
	my $id = $conf->{sid};
  my $serv_conf = Octopussy::Service::Configuration($id);
  my $nb_messages = $#{$serv_conf->{message}} + 1;
	push(@row, { label => $conf->{rank} } );
	push(@row, { label => "$id " . (defined $stats{$id} ? "($stats{$id})" : "(0%)"), 
		link => "$url&service=$id&action=show" } );
	if ($role !~ /ro/i)
	{
		my $dialog = "./dialog.asp?id=delete_device_service&arg1=$id&arg2=$device";
		push(@row, { type => "AAT_Button", align => "R",
									args => { name => "remove", tooltip => "_DELETE",
														popup_link => $dialog } });
		if ($conf->{rank} > 1)
		{
			push(@row, { type => "AAT_Button", align => "R",
										args => { name => "1uparrow", 
										link => "$url&service=$id&action=up" } } );
		}
		else
      { push(@row, { label => "" } ); }

		if ($conf->{rank} < ($#services+1))
		{
			push(@row, { type => "AAT_Button",
										args => { name => "1downarrow",
			            	link => "$url&service=$id&action=down" } } )	;
		}
		else
			{ push(@row, { label => "" } ); }
	}
	push(@table, \@row);
	$nb_services++;
	$total_messages += $nb_messages;
}
push(@table, [ { label => "$nb_services Services / $total_messages Messages", 
	colspan => 5, align => "center" } ]);

if ($role !~ /ro/i)
{
	push(@table, 
		[ { label => "<hr>", colspan => 5 } ], 
		[ { type => "form", args => { method => "post", action => $url } },
			{ type => "AAT_Form_Hidden", 
				args => { name => "device", value => $device } },
    	{ type => "octo_selector_service_and_servicegroup", 
				colspan => 5, align => "center", args => { exclude => \@services} } ],
    [	{ type => "AAT_Form_Submit", colspan => 5, align => "center", 
				args => { value => "_ADD_SERVICE_TO_DEVICE" } }, 
			{ type => "end_form" } ] );	
}
$Response->Include('INC/box.inc', elements => \@table);
%>
