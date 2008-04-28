<%
my %arg = @_;
my $url = $arg{url};
%>
<AAT:Box align="C" title="_REPORT_CATEGORIES" icon="buttons/bt_report">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_CATEGORY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_NB" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $c (Octopussy::Report::Categories())
{
  my ($category, $nb) = ($c->{category}, $c->{nb});
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
  <AAT:BoxCol>
	<AAT:Label value="$category" link="$url?category=$category" /></AAT:BoxCol>
  <AAT:BoxCol align="R"><AAT:Label value="$nb" /></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
<%
if ($Session->{AAT_ROLE} !~ /ro/i)
{
	my @items = ( { label => "_NEW_REPORT", link => "./report_creation.asp" } );
	%><AAT:Menu align="C" items=\@items /><%
}
%>
