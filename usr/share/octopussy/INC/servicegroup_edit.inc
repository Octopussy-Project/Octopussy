<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $lang = $Session->{AAT_LANGUAGE};
my $servicegroup = $arg{servicegroup};
my $url = $arg{url} . "?servicegroup=$servicegroup";
my $dialog_url = "./dialog.asp?id=delete_servicegroup_service";
my $url_sort = $url . "&servicegroup_services_table_sort=";
my $role = $Session->{AAT_ROLE};
my @services = Octopussy::ServiceGroup::Services($servicegroup);
my @exclude = ();
foreach my $s (@services)
{
	print $s->{sid} . "<br>";
	push(@exclude, $s->{sid});
}
my $str = sprintf(AAT::Translation("_MSG_SERVICES_FOR_SERVICEGROUP"),
	$servicegroup);
my @table = (
	[ { label => $str, size => "+1", align => "center", colspan => 5 } ],
	[ { label => "<hr>", 			colspan => 5 } ],
  [ { label => "_RANK", 			link => $url_sort . "rank"  }, 
		{ label => "_SERVICE", 	link => $url_sort . "sid" },
   	{ label => (($role !~ /ro/i) ? "_ACTION" : ""), 
			colspan => 3, 				align => "center" } ],
	[ { label => "<hr>", 			colspan => 5 } ]
  );

foreach my $s (@services)
{
	my @row = ();
	my $id = $s->{sid};
	push(@row, ({ label => $s->{rank} }, { label => $id }));

	if ($role !~ /ro/i)
  {
    my $dialog = "$dialog_url&arg1=$servicegroup&arg2=$id";
    push(@row, { type => "AAT_Button", align => "right",
                  args => { name => "remove", tooltip => "_DELETE", 
														popup_link => $dialog } });
    if ($s->{rank} > 1)
    {
    	push(@row, { type => "AAT_Button", align => "right",
                 		args => { name => "1uparrow",
    								link => "$url&service=$id&action=up" } } );
    }
    else
    	{ push(@row, { label => "" } ); }

    if ($s->{rank} < ($#services+1))
    {
    	push(@row, { type => "AAT_Button", align => "left",
               			args => { name => "1downarrow",
                   	link => "$url&service=$id&action=down" } } )  ;
    }
    else
      { push(@row, { label => "" } ); }
  }
  push(@table, \@row);
}

if ($role !~ /ro/i)
{
	push(@table, 
		[ { label => "<hr>", colspan => 5 } ], 
		[ { type => "form", args => { method => "post", action => $url } },
			{ type => "AAT_Form_Hidden", args => { name => "device", value => $device } },
    	{ type => "octo_selector_service", align => "center", colspan => 5,
				args => { exclude => \@exclude} } ],
    [	{ type => "AAT_Form_Submit", align => "center", colspan => 5, 
				args => { value => "_ADD_SERVICE_TO_SERVICEGROUP" } },
			{ type => "end_form" } ] );	
}
$Response->Include('INC/box.inc', elements => \@table);
%>
