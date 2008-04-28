<%
my %arg = @_;
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "name";
my $lnk = "${url}?alerts_table_sort";
%>
<AAT:Box align="C" title="_ALERTS" icon="buttons/bt_alert">
<AAT:BoxRow>
	<AAT:BoxCol>
	<AAT:Label value="_NAME" link="$lnk=name" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_LEVEL" link="$lnk=level" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TYPE" link="$lnk=type" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_STATUS" link="$lnk=status" /></AAT:BoxCol>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="_ACTION" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="7"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $a (Octopussy::Alert::Configurations($sort))
{
	my ($name, $desc, $level, $type, $status) = 
		($a->{name}, $a->{description}, $a->{level}, $a->{type}, $a->{status});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$name" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><i><AAT:Label value="$desc" /></i></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$level" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$status" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="edit" tooltip="_EDIT"
    link="./alert_edit.asp?alert=$name" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE"
  	popup_link="./dialog.asp?id=delete_alert&arg1=$name&action=remove" />
	</AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
my @items = ( 
	{ label => "_MSG_DYNAMIC_ALERT_CREATION", 
		link => "./alert_dynamic_creation.asp" } ); 
#	{ label => "_MSG_STATIC_ALERT_CREATION" } );
%>
<AAT:Menu align="C" items=\@items />
