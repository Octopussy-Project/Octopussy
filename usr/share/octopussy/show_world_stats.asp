<html>
<body>
<%
AAT::Theme("DEFAULT");
%>
<AAT:PageTheme />
<AAT:Box align="C" title="Daily Statistics">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Date" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Servers" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Max Logs/Hour" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Total Logs/Day" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $query = "SELECT DATE(hour) as day, "
  . "COUNT(DISTINCT(World_Logs.id)) as servers, "
  . "MAX(nb_logs) as max_hour, SUM(nb_logs) as total_day "
  . "FROM World_Logs, World_Servers "
  . "WHERE World_Logs.id=World_Servers.id "
  . "GROUP BY day ORDER BY day DESC";

my ($i, $total_logs) = (0, 0);
foreach my $d (AAT::DB::Query("Octopussy", $query))
{
  $total_logs += $d->{total_day};
  my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%>
  <AAT:BoxRow class="$class">
  <AAT:BoxCol><%= $d->{day} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{servers} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{max_hour} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{total_day} %></AAT:BoxCol>
  </AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol cspan="3"></AAT:BoxCol>
  <AAT:BoxCol align="R"><b><%= $total_logs %></b></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<AAT:Box align="C" title="Country Statistics">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="Country" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Max Logs/Hour" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Total" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
$query = "SELECT country, max(nb_logs) as max_hour, sum(nb_logs) as total_day "
  . "FROM World_Logs, World_Servers "
  . "WHERE World_Logs.id=World_Servers.id "
  . "GROUP BY country ORDER BY total_day desc";

($i, $total_logs) = (0, 0);
foreach my $d (AAT::DB::Query("Octopussy", $query))
{
  $total_logs += $d->{total_day};
  my $flagfile = "AAT/IMG/flags/" . lc($d->{country}) . ".png";
  my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%>
  <AAT:BoxRow class="$class">
  <AAT:BoxCol align="C"><AAT:Picture file="$flagfile" /></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{max_hour} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{total_day} %></AAT:BoxCol>
  </AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol align="R"><b><%= $total_logs %></b></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<AAT:Box align="C" title="Version Statistics">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_VERSION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Max Logs/Hour" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Total" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
$query = "SELECT version, max(nb_logs) as max_hour, sum(nb_logs) as total_day "
  . "FROM World_Logs, World_Servers "
  . "WHERE World_Logs.id=World_Servers.id "
  . "GROUP BY version ORDER BY total_day desc";

($i, $total_logs) = (0, 0);
foreach my $d (AAT::DB::Query("Octopussy", $query))
{
  $total_logs += $d->{total_day};
  my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%>
  <AAT:BoxRow class="$class">
  <AAT:BoxCol align="C"><%= $d->{version} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{max_hour} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{total_day} %></AAT:BoxCol>
  </AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol cspan="2"></AAT:BoxCol>
  <AAT:BoxCol align="R"><b><%= $total_logs %></b></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<AAT:Box align="C" title="TOP 20 Octopussy Servers">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_RANK" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_COUNTRY" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="CPU" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Memory" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_VERSION" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_DEVICES" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="Max Logs/Hour" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="8"><hr></AAT:BoxCol></AAT:BoxRow>
<%
$query = "SELECT country, cpu, memory, version, "
  . "nb_devices, nb_services, MAX(nb_logs) as max "
  . "FROM World_Logs, World_Servers "
  . "WHERE World_Logs.id=World_Servers.id "
  . "GROUP BY World_Logs.id ORDER BY max DESC LIMIT 20";

($i, $total_logs) = (0, 0);
foreach my $d (AAT::DB::Query("Octopussy", $query))
{
  $total_logs += $d->{total_day};
  my $flagfile = "AAT/IMG/flags/" . lc($d->{country}) . ".png";
  my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%>
  <AAT:BoxRow class="$class">
  <AAT:BoxCol align="C"><%= AAT::Padding($i, 2) %></AAT:BoxCol>
  <AAT:BoxCol align="C"><AAT:Picture file="$flagfile" /></AAT:BoxCol> 
  <AAT:BoxCol><%= $d->{cpu} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{memory} %> M</AAT:BoxCol>
  <AAT:BoxCol align="C"><%= $d->{version} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{nb_devices} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><%= $d->{nb_services} %></AAT:BoxCol>
  <AAT:BoxCol align="R"><b><%= $d->{max} %></b></AAT:BoxCol>
  </AAT:BoxRow><%
}
%>
</AAT:Box>

</body>
</html>
