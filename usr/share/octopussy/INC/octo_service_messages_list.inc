<%
my %arg = @_;
my $url = $arg{url};
my $service = $arg{service};
$url .= "?service=$service";
my $url_sort = $url . "&service_messages_table_sort=";
my $sort = (defined $arg{sort} && $arg{sort} ne "") ? lc($arg{sort}) : "rank";
my $lang = $Session->{AAT_LANGUAGE};
my $role = $Session->{AAT_ROLE};
my $serv_conf = Octopussy::Service::Configuration($service);
my $icon = $serv_conf->{icon};
my $site = $serv_conf->{website};
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
	
%>
<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol cspan="2" rspan="2" align="C">
	<AAT:IMG name="$icon" /></AAT:BoxCol>
  <AAT:BoxCol cspan="3" align="C">
	<AAT:Label value="$str" size="+1" /></AAT:BoxCol>
<%
if (AAT::NOT_NULL($site))
{
%><AAT:BoxCol align="R">
	<AAT:Label value="_OFFICIAL_WEBSITE" link_new="$site" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<AAT:Button name="web" link_new="$site" /></AAT:BoxCol><%
}
else
{%><AAT:BoxCol cspan="4"></AAT:BoxCol><%}%>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="3" align="C">
	<AAT:Label value="Service Global Regexp: $gre" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="4"></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="9"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_RANK" link="${url_sort}rank" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_MATCH" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_MSG_ID" link="${url_sort}msg_id" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_LOG_LEVEL" link="${url_sort}loglevel" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TAXONOMY" link="${url_sort}taxonomy" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TABLE" link="${url_sort}table" /></AAT:BoxCol>
	<AAT:BoxCol cspan="3" align="C">
	<%	
	if ($role !~ /ro/i) 
	{ %><AAT:Label value="_ACTION" /><% }
	%>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="9"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $m (@messages)
{
	my $percent = defined $stat{$m->{msg_id}} ? "$stat{$m->{msg_id}}%" : "0%";
 	my ($rank, $id, $loglevel, $taxo, $table) = 
		($m->{rank}, $m->{msg_id}, $m->{loglevel}, $m->{taxonomy}, $m->{table});
 	my $edit_link = "./service_message_edit.asp?service=$service&msgid=$id";
	my $remove_link = "./dialog.asp?id=delete_message&msg=$id&service=$service";
	my $msg_color = Octopussy::Message::Color($m->{pattern});
%>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><AAT:Label value="$rank" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="$percent" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$id" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$loglevel" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$taxo" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$table" style="B" /></AAT:BoxCol>
<%
	if ($role !~ /ro/i)
	{
	%><AAT:BoxCol align="R">
	<AAT:Button name="edit" tooltip="_EDIT" link="$edit_link" /></AAT:BoxCol><%
		if ($m->{rank} > 2)
    {
    %><AAT:BoxCol>
    <AAT:Button name="2uparrow" link ="$url&msgid=$id&action=top" />
    </AAT:BoxCol><%
    }
    else
      { %><AAT:BoxCol></AAT:BoxCol><% }
		if ($m->{rank} < $#messages+1)     
		{     
		%><AAT:BoxCol>
		<AAT:Button name="1downarrow" link ="$url&msgid=$id&action=down" />
		</AAT:BoxCol><%     
		}
		else
			{ %><AAT:BoxCol></AAT:BoxCol><% }
	}
%>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="6">
	<AAT:Label value="$msg_color" size="-2" /></AAT:BoxCol>	
<%
  if ($role !~ /ro/i)
  {
	%><AAT:BoxCol align="R">
  <AAT:Button name="remove" tooltip="_REMOVE" popup_link="$remove_link" /></AAT:BoxCol><%	
		if ($m->{rank} > 1)
    {
    %><AAT:BoxCol>
    <AAT:Button name="1uparrow" link ="$url&msgid=$id&action=up" />
    </AAT:BoxCol><%
    }
    else
      { %><AAT:BoxCol></AAT:BoxCol><% }
		if ($m->{rank} < $#messages)
    {
    %><AAT:BoxCol>
    <AAT:Button name="2downarrow" link ="$url&msgid=$id&action=bottom" />
    </AAT:BoxCol><%
    }
    else
      { %><AAT:BoxCol></AAT:BoxCol><% }
	}
%>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="9"><hr></AAT:BoxCol></AAT:BoxRow>
<%
}
%>
</AAT:Box>
<%
}
%>
