<%
my %arg = @_;
my $url = $arg{url};
my $sort = $arg{sort} || "name";
my $login = $Session->{AAT_LOGIN};
my $dlg = "/dialog.asp?id=delete_search_template&action=remove";
my @templates = Octopussy::Search_Template::List_Any_User($sort);
%>
<AAT:Box align="C" title="_SEARCH_TEMPLATES" icon="buttons/bt_search_template">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_NAME" style="B"
    link="$url?search_templates_table_sort=name"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_USER" style="B"
    link="$url?search_templates_table_sort=user"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $tpl (@templates)
{
	my ($template, $user) = ($tpl->{name}, $tpl->{user});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
	%><AAT:BoxRow class="$class"> 
	<AAT:BoxCol><AAT:Label value="$template" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$user" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Button name="remove" tooltip="_REMOVE"
		popup_link="$dlg&arg1=$template&arg2=$user" /></AAT:BoxCol>
	</AAT:BoxRow><%	
}
%>
</AAT:Box>
