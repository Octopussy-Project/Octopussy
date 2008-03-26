<%
my %arg = @_;
my $url = $arg{url};
$url .= "?"	if ($url !~ /\?/);
my $name = $arg{name};
my $mode = $arg{mode} || "daily";
my $file = "./rrd/${name}_${mode}.png";
%>
<AAT:Box>
	<AAT:BoxRow>
	<AAT:BoxCol align="center" cspan="5">
	<% 
	if (-f $file)
		{ %><AAT:Picture file="$file" /><% }
	else
		{ %><AAT:Label value="_MSG_NO_GRAPH_AVAILABLE" /><% } %>
	</AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol align="right">
	<AAT:Label value="_HOURLY_STATS" size="-1" link="${url}&rrd_mode=hourly"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_DAILY_STATS" size="-1" link="${url}&rrd_mode=daily"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_WEEKLY_STATS" size="-1" link="${url}&rrd_mode=weekly"/></AAT:BoxCol>
	<AAT:BoxCol align="C">
  <AAT:Label value="_MONTHLY_STATS" size="-1" link="${url}&rrd_mode=monthly"/></AAT:BoxCol>
	<AAT:BoxCol align="left">
  <AAT:Label value="_YEARLY_STATS" size="-1" link="${url}&rrd_mode=yearly"/></AAT:BoxCol>
	</AAT:BoxRow>
</AAT:Box>
