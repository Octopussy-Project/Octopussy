<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $sort = $arg{sort}
%>
<AAT:Box align="center" title="_STORAGES" icon="buttons/bt_storage">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DIRECTORY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $s (Octopussy::Storage::Configurations($sort))
{
	my ($name, $dir) = ($s->{s_id}, $s->{directory});
	my $dialog = "./dialog.asp?id=delete_storage&arg1=$name";
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$name" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$dir" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if ($name !~ /^DEFAULT$/)
	{
		%><AAT:Button name="remove" popup_link="$dialog" tooltip="_REMOVE" /><%
	}
	%></AAT:BoxCol></AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:Form action="$arg{url}">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="name" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Entry name="directory" size="40" /></AAT:BoxCol> 
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="3">
	<AAT:Form_Hidden name="action" value="add" />
	<AAT:Form_Submit value="_ADD_STORAGE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Form>
</AAT:Box>
