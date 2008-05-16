<%
my %arg = @_;

my $url = $arg{url};
my $service = $arg{service} || "-ANY-";
my $loglevel = $arg{loglevel} || "-ANY-";
my $taxonomy = $arg{taxonomy} || "-ANY-";
my $table = $arg{table} || "-ANY-";
my $sort = $arg{sort} || "msg_id";
my $url_sort = $url . "?sort";
my $role = $Session->{AAT_ROLE};
my @messages = Octopussy::Service::Messages_Configurations(
	($service eq "-ANY-" ? undef : $service), $sort);
%>
<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_RANK" link="$url_sort=rank" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="Msg ID" link="$url_sort=msg_id" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_LOG_LEVEL" link="$url_sort=loglevel" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TAXONOMY" link="$url_sort=taxonomy" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TABLE" link="$url_sort=table" /></AAT:BoxCol>
 	<AAT:BoxCol align="C"><%
	if ($role !~ /ro/i)
    { %><AAT:Label value="_ACTION" style="B" /> <% } %>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<%	
my @table = (
  	[ { label => "<hr>", colspan => 6 } ] );

foreach my $m (@messages)
{
	if ((($m->{loglevel} eq $loglevel) || ($loglevel eq "-ANY-"))
		&& (($m->{taxonomy} =~ /^$taxonomy\.?.*/) || ($taxonomy eq "-ANY-"))
		&& (($m->{table} eq $table) || ($table eq "-ANY-")))
	{
		my ($id, $rank, $loglevel, $taxo, $table) = 
			($m->{msg_id}, $m->{rank}, $m->{loglevel}, $m->{taxonomy}, $m->{table});
		my $service = $1	if ($id =~ /^(\S+):.+$/);
		my $msg_color = Octopussy::Message::Color($m->{pattern});
		my $edit_lnk = "./service_message_edit.asp?service=$service&msgid=$id"; 
		my $rm_lnk = "./dialog.asp?id=delete_message&msg=$id&service=$m->{service}"; %>
		<AAT:BoxRow>
  		<AAT:BoxCol><AAT:Label value="$rank" style="B" /></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="$id" style="B" /></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="$loglevel" style="B" /></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="$taxo" style="B" /></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="$table" style="B" /></AAT:BoxCol>
			<AAT:BoxCol><%
			if ($role !~ /ro/i)
    	{
			%><AAT:Button name="remove" tooltip="_REMOVE" popup_link="$rm_lnk" /><% 
			}
		%></AAT:BoxCol>
		</AAT:BoxRow>
		<AAT:BoxRow>
			<AAT:BoxCol cspan="5"><AAT:Label value="$msg_color" size="-2" /></AAT:BoxCol>
			<AAT:BoxCol><%
			if ($role !~ /ro/i)
      {
      %><AAT:Button name="edit" tooltip="_EDIT" popup_link="$edit_lnk" /><%
      }
    %></AAT:BoxCol>
    </AAT:BoxRow>
		<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow><%
	}
}
%></AAT:Box>
