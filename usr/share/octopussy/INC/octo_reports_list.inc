<%
my %arg = @_;
my $url = $arg{url};
my $category = $arg{category};
my $sort = (defined $arg{sort} ? lc($arg{sort}) : "name");
my $lnk = "${url}?category=$category&reports_table_sort";
my $role = $Session->{AAT_ROLE};
%>
<AAT:Box align="C" title="_REPORTS" icon="buttons/bt_report">
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="_NAME" link="$lnk=name" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
  <AAT:BoxCol>
  <AAT:Label value="_TYPE" link="$lnk=type" /></AAT:BoxCol>
 <AAT:BoxCol align="C" cspan="2">
  <AAT:Label value="_ACTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $r (Octopussy::Report::Configurations($sort, $category))
{
  my ($name, $desc, $type) = 
		($r->{name}, $Server->HTMLEncode($r->{description}), $r->{graph_type});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
  <AAT:BoxCol><AAT:Label value="$name" link="$url?report=$name" /></AAT:BoxCol>
  <AAT:BoxCol><i><AAT:Label value="$desc" /></i></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="edit" tooltip="_EDIT"
    link="./report_edit.asp?report=$name" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_report&arg1=$name&action=remove" />
  </AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
if ($role !~ /ro/i)
{
	my @items = ( { label => "_NEW_REPORT", 
		link => "./report_creation.asp?category=$category" } );
	%><AAT:Menu align="C" items=\@items /><%
}
%>
