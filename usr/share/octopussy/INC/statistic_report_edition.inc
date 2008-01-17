<%
my %arg = @_;

my $statistic_report = $arg{statistic_report};
my $device = $arg{device};
my $service = $arg{service};
my $table = $arg{table};
my $url = $arg{url};
my $conf = Octopussy::Statistic_Report::Configuration($statistic_report);
my @tables = Octopussy::Table::List();
	
my @table = (
	[ { label => "_STATISTIC_REPORT_EDITION", colspan => 2,
			align => "center", style => "bold" } ],
	[ { label => "<hr>", colspan => 2 } ],
	[	{ type => "form", 
			args => { method => "post", action => "./statistic_report_edit.asp" } },
		{ type => "AAT_Form_Hidden", 
			args => { name => "old_statistic_report", value => $conf->{name} } },
		{ label => "_NAME", style => "bold"}, 
		{ type => "AAT_Entry", 
			args => { name => "name", value => $conf->{name}, length => 50 } } ],
	[ { label => "_DESCRIPTION", style => "bold"},
    { type => "AAT_Entry", 
			args => { name => "description", 
			value => $conf->{description}, length => 50 } } ],
	[ { label => "_DEVICE", style => "bold" },
		{ type => "octo_selector_device_and_devicegroup_dynamic",
		 	args => { url => "$url?statistic_report=$statistic_report&device=", 
								selected => $device } } ],
	[ { label => "_SERVICE", style => "bold" },
	 	{ type => "octo_selector_service_dynamic",
			args => { url => "$url?statistic_report=$statistic_report&device=$device&service=",
						   	device => $device, selected => $service } } ],
	[ { label => "_TABLE", style => "bold" },
		{ type => "selector_dynamic", 
			args => { name => "table", 
				url => "$url?statistic_report=$statistic_report&table=", 
				list => \@tables, selected => $table || $conf->{table} } } ],
	[ { label => "<hr>", colspan => 2 } ],
	[ { label => "_DATASOURCES", style => "bold" },
	 	{ type => "octo_selector_rrdgraph_datasource",
			args => { name => "datasource1", table => $Session->{table} } } ],
	[ { label => "" },
		{ type => "octo_selector_rrdgraph_datasource",
			args => { name => "datasource2", none => 1,
			table => $Session->{table} } } ],
	[ { label => "" },
		{ type => "octo_selector_rrdgraph_datasource",
			args => { name => "datasource3", none => 1,
			table => $Session->{table} } } ],
	[ { label =>  "_DATASOURCES_VALUE", style => "bold" },
	 	{ type => "octo_selector_rrdgraph_datasource_value",
			args => { name => "datasources_value", table => $Session->{table} } } ]
	);

push(@table, 
	[ { label => "<hr>", colspan => 2 } ],
 	[ { type => "AAT_Form_Hidden", args => { name => "modify", value => "yes" } },
  	{ type => "AAT_Form_Submit", align => "center", colspan => 5, 
			args => { value => "_UPDATE" } },
   	{ type => "end_form" } ] );

$Response->Include('INC/box.inc', elements => \@table);
%>
