<%
my $sort = $Request->QueryString("servicegroups_table_sort");
%>
<AAT:Box align="C" title="_SERVICEGROUPS" icon="buttons/bt_servicegroup">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_GROUP_NAME" style="B" 
		link="$url?servicegroups_table_sort=sg_id"/></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" 
		link="$url?servicegroups_table_sort=description"/></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="C" cspan="2"><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $sg (Octopussy::ServiceGroup::Configurations($sort))
{
	my ($id, $desc) = ($sg->{sg_id}, $sg->{description});
	my $services_list = "";
	foreach my $sgc (ARRAY($sg->{service}))
		{ $services_list .= "$sgc->{sid}, "; }
	$services_list =~ s/, $//;
	$services_list =~ s/^(.{60})(.*)/$1\.\.\./;
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
	$i++;
%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$id" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$desc" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$services_list" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Button name="edit" tooltip="_EDIT" 
		link="./servicegroup_edit.asp?servicegroup=$id" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_servicegroup&arg1=$id&action=remove" />
	</AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
<AAT:Form action="$url">
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Entry name="servicegroup" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="sg_description" /></AAT:BoxCol>
	<AAT:BoxCol align="C">
	<AAT:Inc file="selector_multi_service" name="services" size="2" />
	</AAT:BoxCol>
	<AAT:BoxCol cspan="2" align="C">
	<AAT:Form_Submit value="_NEW_SERVICEGROUP" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
