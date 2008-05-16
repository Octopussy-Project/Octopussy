<WebUI:PageTop title="Report Creation" />
<%
my $f = $Request->Form();
my $category = $Request->QueryString("category");
my $x = $Session->{x};
my $y = $Session->{y};
my $url = "./report_creation.asp";

if (!defined $Session->{title})
{
	%><AAT:Inc file="octo_report_data_configurator" category="$category" 
		url="$url" /><%
}
elsif ((!defined $Session->{selected}) && (!defined $f->{datasource1}))
{
	if ($Session->{graph_type} !~ /^rrd_/)
		{ %><AAT:Inc file="octo_report_query_configurator" url="$url"/><% }
	else
		{ %><AAT:Inc file="octo_report_rrdgraph_configurator" url="$url" /><% }
}
elsif (($Session->{graph_type} !~ /^rrd_/) && (!defined $x))
{
	my ($query, $columns) = 
		Octopussy::DB::SQL_Select_Function(AAT::ARRAY($Session->{select}));
	my $order_by = $Session->{order_by};
	my $sort_dir = $Session->{sort_direction};
  $query .= "FROM $Session->{table}" 
		. ($Session->{where} ne "" ? " WHERE $Session->{where}" : "")
    . ($Session->{group_by} ne "" ? " GROUP BY $Session->{group_by}" : "")
    . ($order_by ne "" ? 
			" ORDER BY $order_by " . ($sort_dir eq "ASCENDING" ? "asc" : "desc") : "")
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
  		push(@datasources, 
				Octopussy::DB::SQL_As_Substitution($f->{"datasource$i"}))	
				if ($f->{"datasource$i"} ne "");
		}
		my ($query, $columns) =
  		Octopussy::DB::SQL_Select_Function($f->{rrd_timeline}, @datasources, 
				$f->{datasources_value});
		my $dhm = Octopussy::DB::SQL_As_Substitution($f->{rrd_timeline});
		$query .= "FROM $Session->{table} GROUP BY $dhm," . join(",", @datasources);

		my $dsv = Octopussy::DB::SQL_As_Substitution($f->{datasources_value});
		if (($f->{datasource1} ne "") && ($Session->{AAT_ROLE} !~ /ro/i))
		{
  		Octopussy::Report::New(
    		{ name => $Session->{title}, description => $Session->{description},
      		category => ($Session->{new_category} || $Session->{category}),
					datasource1 => $f->{datasource1}, datasource2 => $f->{datasource2}, 
					datasource3 => $f->{datasource3}, datasources_value => $dsv, 
					timeline => $dhm, graph_type => $Session->{graph_type}, 
					rrd_step => $Session->{rrd_step}, table => $Session->{table}, 
					taxonomy => $Session->{taxonomy}, query => $query,
      		graph_title => $f->{graph_title}, graph_ylabel => $f->{graph_ylabel},
      		graph_width => $f->{graph_width}, graph_height => $f->{graph_height} }
				);
			AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Report", $Session->{title});	
		}
		Purge_Session();
	}
	else
	{
		$x = Octopussy::DB::SQL_As_Substitution($x);
		$y = Octopussy::DB::SQL_As_Substitution($y);
	
		my @columns_name = ();
		my ($query, $columns) = 
			Octopussy::DB::SQL_Select_Function(AAT::ARRAY($Session->{select}));
		foreach my $i (0..$#{$Session->{select}})
			{ push(@columns_name, $Session->{"column_name_$i"}); }
	
		if ($Session->{AAT_ROLE} !~ /ro/i)
		{
			Octopussy::Report::New(
				{ name => $Session->{title}, description => $Session->{description},
					category => ($Session->{new_category} || $Session->{category}), 
					graph_type => $Session->{graph_type}, table => $Session->{table}, 
					taxonomy => $Session->{taxonomy}, query => $Session->{query}, 
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
