<%
my %arg = @_;
my $url = $arg{url};
my $url_sort = $url . "?category=$arg{category}&reports_table_sort=";
my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN});
my @res_reports = ARRAY($restricts->{report});
my @report_types = Octopussy::Report::List($arg{category}, \@res_reports);
%>
<AAT:Box align="C" icon="buttons/bt_report" title="_REPORTS_VIEWER">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_NAME" link="${url_sort}name" /></AAT:BoxCol>
	<AAT:BoxCol align="R">
	<AAT:Label value="_NB_REPORTS" link="${url_sort}nb_reports" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $r (@report_types)
{
  my $reports = Octopussy::Data_Report::List($r);
  my $nb = 0;
  foreach my $r (sort keys %{$reports})
    { $nb++; }
%><AAT:BoxRow><%
	if ($nb > 0)
  { 
%><AAT:BoxCol><AAT:Label value="$r" link="$url?report=$r" /></AAT:BoxCol><%
	}
	else
	{
%><AAT:BoxCol><AAT:Label value="$r" /></AAT:BoxCol><%
	}
%><AAT:BoxCol align="R"><AAT:Label value="$nb" /></AAT:BoxCol>
</AAT:BoxRow><%
}
%>
</AAT:Box>
