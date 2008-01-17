<%
my %arg = @_;
#use utf8;

my $url = $arg{url};
my $service = $arg{service};
$url .= "?service=$service";
my $url_sort = $url . "&service_messages_table_sort=";
my $sort = (defined $arg{sort} && $arg{sort} ne "") ? lc($arg{sort}) : "rank";
my $lang = $Session->{AAT_LANGUAGE};
my $role = $Session->{AAT_ROLE};
my $serv_conf = Octopussy::Service::Configuration($service);
my %stat = Octopussy::Service::Messages_Statistics($service, 5);
my @messages = Octopussy::Service::Messages_Configurations($service, $sort);
my $gre = Octopussy::Service::Global_Regexp($service);

if ($#messages < 0)
{
	my $str = sprintf(AAT::Translation("_MSG_NO_MSG_FOR_SERVICE"), 
		$service, $serv_conf->{version});
	%><AAT:Label value="$str" size="+1" /><%
}
else
{
	my $str = sprintf(AAT::Translation("_MSG_MSGS_FOR_SERVICE"), 
		$service, $serv_conf->{version});
	my @table = (
  	[ { type => "AAT_IMG", align => "center", colspan => 2, rowspan => 2,
				args => { name => $serv_conf->{icon}, width => 64 } },
			{ label => $str, size => "+1", align => "center", colspan => 6 } ],
		[ { label => "<b>Service Global Regexp:</b> $gre", 
				align => "center", colspan => 6 } ],
  	[ { label => "<hr>", colspan => 8 } ],
  	[ { label => "_RANK", link => $url_sort . "rank" },
			{ label => "_MATCH" },
    	{ label => "_MSG_ID", link => $url_sort . "msg_id" },
    	{ label => "_LOG_LEVEL", link => $url_sort . "loglevel" },
    	{ label => "_TAXONOMY", link  => $url_sort . "taxonomy" },
    	{ label => "_TABLE", link => $url_sort . "table" },
    	{ label => (($role !~ /ro/i) ? "_ACTION" : ""),
				align => "center", colspan => 2 } ],
  	[ { label => "<hr>", colspan => 8 } ] );

	foreach my $m (@messages)
	{
		my $percent = defined $stat{$m->{msg_id}} ? "$stat{$m->{msg_id}}%" : "0%";
		my $id = $m->{msg_id};
		my $edit_link = "./service_message_edit.asp?service=$service&msgid=$id";
		my @row = ();
		push(@row, { label => $m->{rank}, style => "B" } );
		push(@row, { label => $percent } );
 		push(@row, { label => $id, style => "B" } );
		push(@row, { label => $m->{loglevel}, style => "B" } );
		push(@row, { label => $m->{taxonomy}, style => "B" } );
		push(@row, { label => $m->{table}, style => "B" } );
		if ($role !~ /ro/i)
		{
			push(@row, { type => "AAT_Button", args => { name => "edit",
										tooltip => "_EDIT", link => $edit_link } });
			if ($m->{rank} > 1)
			{
				push(@row, { type => "AAT_Button", args => { name => "1uparrow", 
										link => "$url&msgid=$id&action=up" } } );
			}
			else
				{ push(@row, { label => "" } ); }
		}
		push(@table, \@row);

		my $msg_color = Octopussy::Message::Color($m->{pattern});
		my @row2 = ();
		push(@row2, { label => $msg_color, size => "-2", colspan => 6 } );
		if ($role !~ /ro/i)
		{
			my $remove_link = "./dialog.asp?id=delete_message&msg=$id&service=$service";
			push(@row2, { type => "AAT_Button", args => { name => "remove", 
										tooltip => "_REMOVE", popup_link => $remove_link } } );
			if ($m->{rank} < $#messages+1)
			{
				push(@row2, { type => "AAT_Button", args => { name => "1downarrow", 
										link => "$url&msgid=$id&action=down" } } );
			}
			else
				{ push(@row2, { label => "" } ); }
		}
		push(@table, \@row2);
		push(@table, [ { label => "<hr>", colspan => 8 } ]);
	}
	$Response->Include('INC/box.inc', elements => \@table);
}
%>
