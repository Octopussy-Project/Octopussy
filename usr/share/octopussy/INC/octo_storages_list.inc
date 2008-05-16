<% my %arg = @_; %>
<AAT:Box align="C" title="_STORAGES" icon="buttons/bt_storage">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DIRECTORY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $s (Octopussy::Storage::Configurations($arg{sort}))
{
	my ($name, $dir) = ($s->{s_id}, $s->{directory});
	my $dialog = "./dialog.asp?id=delete_storage&arg1=$name";
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
	%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$name" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$dir" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if ($name !~ /^DEFAULT$/)
	{ %><AAT:Button name="remove" popup_link="$dialog" tooltip="_REMOVE" /><% }
	%></AAT:BoxCol></AAT:BoxRow><%
}
%>
<AAT:Form action="$arg{url}">
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="directory" size="40" /></AAT:BoxCol> 
	<AAT:BoxCol align="C"><AAT:Form_Submit value="_ADD_STORAGE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:Form_Hidden name="action" value="add" />
</AAT:Form>
</AAT:Box>
