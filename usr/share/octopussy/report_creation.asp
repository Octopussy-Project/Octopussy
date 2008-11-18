<WebUI:PageTop title="Report Creation" />
<%
my $f = $Request->Form();
my $category = $Request->QueryString("category");
my $x = $Session->{x};
my $y = $Session->{y};
my $url = "./report_creation.asp";

my $group_by_add = $Request->QueryString("group_by_add");
my $group_by_remove = $Request->QueryString("group_by_remove");
my $order_by_add = $Request->QueryString("order_by_add");
my $order_by_remove = $Request->QueryString("order_by_remove");

if (AAT::NOT_NULL($group_by_add))
{
	my @group_by_list = @{$Session->{group_by}};
	push(@group_by_list, $group_by_add);
	$Session->{group_by} = \@group_by_list;
}
if (AAT::NOT_NULL($group_by_remove))
{
	my @group_by_list = ();
  foreach my $gb (@{$Session->{group_by}})
		{ push(@group_by_list, $gb)	if ($gb ne $group_by_remove); }
  $Session->{group_by} = \@group_by_list;
}
if (AAT::NOT_NULL($order_by_add))
{
  my @order_by_list = @{$Session->{order_by}};
  push(@order_by_list, $order_by_add);
  $Session->{order_by} = \@order_by_list;
}
if (AAT::NOT_NULL($order_by_remove))
{
  my @order_by_list = ();
  foreach my $ob (@{$Session->{order_by}})
    { push(@order_by_list, $ob) if ($ob ne $order_by_remove); }
  $Session->{order_by} = \@order_by_list;
}

if (AAT::NULL($Session->{title}))
{
	%><AAT:Inc file="octo_report_data_configurator" category="$category" 
		url="$url" /><%
}
elsif ((AAT::NULL($Session->{selected})) && (AAT::NULL($f->{datasource1})))
{
	if ($Session->{graph_type} !~ /^rrd_/)
		{ %><AAT:Inc file="octo_report_query_select_configurator" url="$url"/><% }
	else
		{ %><AAT:Inc file="octo_report_rrdgraph_configurator" url="$url" /><% }
}
elsif (($Session->{graph_type} !~ /^rrd_/) && (AAT::NULL($Session->{sort_direction})))
{
	%><AAT:Inc file="octo_report_query_where_configurator" url="$url"/><%
}
elsif (($Session->{graph_type} !~ /^rrd_/) && (AAT::NULL($x)))
{
	my ($query, $columns) = 
		Octopussy::DB::SQL_Select_Function(AAT::ARRAY($Session->{select}));
	my $sql_group_by = (AAT::NOT_NULL($Session->{group_by}) 
		? " GROUP BY " . join(", ", @{$Session->{group_by}}) : "");
	$sql_group_by =~ 
		s/Octopussy::Plugin::(\S+?)::(\S+?)\((\S+?)\)/Plugin_$1_$2__$3/g;
	my $sql_order_by = (AAT::NOT_NULL($Session->{order_by})
    ? " ORDER BY " . join(", ", @{$Session->{order_by}}) : "") 
		. ($Session->{sort_direction} eq "ASCENDING" ? " asc" : " desc");
	$sql_order_by =~ 
		s/Octopussy::Plugin::(\S+?)::(\S+?)\((\S+?)\)/Plugin_$1_$2__$3/g;
  $query .= "FROM $Session->{table}" 
		. ($Session->{where} ne "" ? " WHERE $Session->{where}" : "")
    . $sql_group_by . $sql_order_by
		. ($Session->{limit} ne "" ? " LIMIT $Session->{limit}" : "");
	$Session->{query} = $query;
	%><AAT:Inc file="octo_report_display_configurator" url="$url" /><%
}
else
{
	if ($Session->{graph_type} =~ /^rrd_/)
	{
		my @datasources = ();
		for my $i (1..3)
		{
  		push(@datasources, $f->{"datasource$i"})
				if ($f->{"datasource$i"} ne "");
		}
		my ($query, $columns) =
  		Octopussy::DB::SQL_Select_Function($f->{rrd_timeline}, @datasources, 
				$f->{datasources_value});
		my $dhm = $f->{rrd_timeline};
		$query .= "FROM $Session->{table} GROUP BY $dhm," . join(",", @datasources);

		my $dsv = $f->{datasources_value};
		if (($f->{datasource1} ne "") && ($Session->{AAT_ROLE} !~ /ro/i))
		{
  		Octopussy::Report::New(
    		{ name => $Session->{title}, description => $Session->{description},
      		category => ($Session->{new_category} || $Session->{category}),
					datasource1 => $f->{datasource1}, datasource2 => $f->{datasource2}, 
					datasource3 => $f->{datasource3}, datasources_value => $dsv, 
					timeline => $dhm, graph_type => $Session->{graph_type}, 
					rrd_step => $Session->{rrd_step}, table => $Session->{table}, 
					loglevel => $Session->{loglevel},  taxonomy => $Session->{taxonomy}, 
					query => $query,
      		graph_title => $f->{graph_title}, graph_ylabel => $f->{graph_ylabel},
      		graph_width => $f->{graph_width}, graph_height => $f->{graph_height} }
				);
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Report", $Session->{title});	
		}
		Purge_Session();
	}
	else
	{
		my @columns_name = ();
		my ($query, $columns) = 
			Octopussy::DB::SQL_Select_Function(AAT::ARRAY($Session->{select}));
		my $last_select = scalar(@{$Session->{select}}) - 1;
		foreach my $i (0..$last_select)
			{ push(@columns_name, $Session->{"column_name_$i"}); }
	
		if ($Session->{AAT_ROLE} !~ /ro/i)
		{
			Octopussy::Report::New(
				{ name => $Session->{title}, description => $Session->{description},
					category => ($Session->{new_category} || $Session->{category}), 
					graph_type => $Session->{graph_type}, table => $Session->{table}, 
					loglevel => $Session->{loglevel}, taxonomy => $Session->{taxonomy}, 
					query => $Session->{query}, 
					columns => join(",", AAT::ARRAY($columns)), 
					columns_name => join(",", @columns_name),
					x => $x, y => $y });
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Report", $Session->{title});
		}
		Purge_Session();
	}
	$Response->Redirect("./reports.asp");
}
%>
<WebUI:PageBottom />
