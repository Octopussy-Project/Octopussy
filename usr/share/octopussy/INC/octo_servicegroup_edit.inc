<%
my %arg = @_;
my $lang = $Session->{AAT_LANGUAGE};
my $servicegroup = $arg{servicegroup};
my $url = $arg{url} . "?servicegroup=$servicegroup";
my $dialog_url = "./dialog.asp?id=delete_servicegroup_service";
my $url_sort = $url . "&servicegroup_services_table_sort";
my $role = $Session->{AAT_ROLE};
my @services = Octopussy::ServiceGroup::Services($servicegroup);
my @exclude = ();
foreach my $s (@services)
	{ push(@exclude, $s->{sid}); }
my $str = sprintf(AAT::Translation("_MSG_SERVICES_FOR_SERVICEGROUP"),
	$servicegroup);
%>
<AAT:Box align="C" title="$str" icon="buttons/bt_servicegroup">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_RANK" link="$url_sort=rank" /></AAT:BoxCol>
  <AAT:BoxCol align="C">
  <AAT:Label value="_SERVICE" link="$url_sort=sid" /></AAT:BoxCol>
  <AAT:BoxCol align="C" cspan="3"><%
  if ($role !~ /ro/i)
    { %><AAT:Label value="_ACTION" style="B" /> <% } %>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $nb_services = 0;
foreach my $s (@services)
{
	my ($rank, $id) = ($s->{rank}, $s->{sid}); 
	my $dialog = "$dialog_url&arg1=$servicegroup&arg2=$id"; 
	my $class = (($nb_services%2) ? "boxcolor1" : "boxcolor2"); %>
<AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$rank" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$id" /></AAT:BoxCol><%
	if ($role !~ /ro/i)
  {
    %><AAT:BoxCol align="R"><%
    if ($rank > 1)
    {
  %><AAT:Button name="1uparrow" link="$url&service=$id&action=up" /><%
    }
    %></AAT:BoxCol><AAT:BoxCol align="C"><%
    if ($rank < ($#services+1))
    {
  %><AAT:Button name="1downarrow" link="$url&service=$id&action=down" /><%
    }
    %></AAT:BoxCol>
    <AAT:BoxCol>
    <AAT:Button name="remove" tooltip="_REMOVE" popup_link="$dialog" />
    </AAT:BoxCol><%
  }
  else
    { %><AAT:BoxCol cspan="3"></AAT:BoxCol><% } 
	$nb_services++; 
%></AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
if ($role !~ /ro/i)
{%>
<AAT:Form action="$url">
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Inc file="octo_selector_service" exclude=\@exclude />
  </AAT:BoxCol>
  <AAT:BoxCol cspan="3"><AAT:Form_Submit value="_ADD_SERVICE_TO_SERVICEGROUP" />
  </AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form><%
}
%>
</AAT:Box>
