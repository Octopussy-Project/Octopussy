<%
my %arg = @_;

my $url = $arg{url};
my $service = $arg{service} || "-ANY-";
my $loglevel = $arg{loglevel} || "-ANY-";
my $taxonomy = $arg{taxonomy} || "-ANY-";
my $table = $arg{table} || "-ANY-";
my $sort = $arg{sort} || "msg_id";
my $url_sort = $url . "?sort=";
my $role = $Session->{AAT_ROLE};
my @messages = Octopussy::Service::Messages_Configurations(($service eq "-ANY-" ? undef : $service), $sort);
	
my @table = (
  	[ { label => "_RANK", 			link => $url_sort . "rank" },
    	{ label => "Msg ID",    	link => $url_sort . "msg_id" },
    	{ label => "_LOG_LEVEL", 	link => $url_sort . "loglevel" },
    	{ label => "_TAXONOMY",  	link => $url_sort . "taxonomy" },
    	{ label => "_TABLE",     	link => $url_sort . "table" },
    	{ label => (($role !~ /ro/i) ? "_ACTION" : ""), 
				align => "center", style => "B" } ],
  	[ { label => "<hr>", colspan => 6 } ] );

foreach my $m (@messages)
{
	if ((($m->{loglevel} eq $loglevel) || ($loglevel eq "-ANY-"))
		&& (($m->{taxonomy} =~ /^$taxonomy\.?.*/) || ($taxonomy eq "-ANY-"))
		&& (($m->{table} eq $table) || ($table eq "-ANY-")))
	{
		my $id = $m->{msg_id};
		my $service = $1	if ($id =~ /^(\S+):.+$/);
		my $edit_link = "./service_message_edit.asp?service=$service&msgid=$id";
		my @row = ();
		push(@row, { label => $m->{rank}, style => "B" } );
 		push(@row, { label => $id, style => "B" } );
		push(@row, { label => $m->{loglevel}, style => "B" } );
		push(@row, { label => $m->{taxonomy}, style => "B" } );
		push(@row, { label => $m->{table}, style => "B" } );
		if ($role !~ /ro/i)
    {
      my $remove_link = "./dialog.asp?id=delete_message&msg=$id&service=$m->{service}";
      push(@row, { type => "AAT_Button", align => "C", 
				args => { name => "remove", tooltip => "_REMOVE", 
									popup_link => $remove_link } } );
    }
		push(@table, \@row);

		my $msg_color = Octopussy::Message::Color($m->{pattern});
		my @row2 = ();
		push(@row2, { label => $msg_color, size => "-2", colspan => 5 } );
		push(@row2, { type => "AAT_Button", align => "C", 
			args => { name => "edit", tooltip => "_EDIT", link => $edit_link } });
		push(@table, \@row2);
		push(@table, [ { label => "<hr>", colspan => 6 } ]);
	}
}
$Response->Include('INC/box.inc', elements => \@table);
%>
