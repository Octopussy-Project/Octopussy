<%
my %arg = @_;
my $url = $arg{url};
my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN}, $Session->{AAT_USER_TYPE});
my @res_reports = ARRAY($restricts->{report});
%>
<AAT:Box align="C" title="_REPORTS_VIEWER" icon="buttons/bt_report">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="_CATEGORY" style="B" /></AAT:BoxCol>
	<AAT:BoxCol align="R"><AAT:Label value="_NB" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $r (Octopussy::Report::Categories(@res_reports))
{
	my ($cat, $nb) = ($r->{category}, $r->{nb});
%><AAT:BoxRow>
  <AAT:BoxCol><AAT:Label value="$cat" link="$url?category=$cat" /></AAT:BoxCol>
  <AAT:BoxCol align="R"><AAT:Label value="$nb" /></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
