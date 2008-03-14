<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my $role = $Session->{AAT_ROLE};
my %arg = @_;
my $report = $arg{report};
my $rconf = Octopussy::Report::Configuration($report);
my $desc = $rconf->{description};
my $reports = Octopussy::Data_Report::List($report);
my $url_base = "./report_show.asp?report_type=$report";
my $lang = $Session->{AAT_LANGUAGE};

my $restricts = AAT::User::Restrictions("Octopussy", $Session->{AAT_LOGIN});
my @res_reports = AAT::ARRAY($restricts->{report});
my $in_restriction = ($#res_reports >= 0 ? 0 : 1);
foreach my $res (@res_reports)
	{ $in_restriction = 1 if ($rconf->{name} eq $res); }
$Response->Redirect("./restricted_reports_viewer.asp")	if (! $in_restriction);

my %type = (
	csv => { mime => "csv", tooltip => "_REPORT_CSV" },
	html => { mime => "html", tooltip => "_REPORT_HTML" },
	pdf => { mime => "pdf", tooltip => "_REPORT_PDF" },
	png => { mime => "log", tooltip => "_REPORT_RRDGraph" },
	xml => { mime => "xml", tooltip => "_REPORT_XML" } );
%>
<AAT:Box align="C" icon="buttons/bt_report" title="_REPORTS_VIEWER">
<AAT:BoxRow>
	<AAT:BoxCol cspan="5">
	<AAT:Label value="_REPORT" style="B" /><AAT:Label value=": $report" />
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="5">
	<AAT:Label value="_DESCRIPTION" style="B" /><AAT:Label value=": $desc" />
	</AAT:BoxCol>	
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my ($count, $month, $year) = (0, "", "");

foreach my $r (sort keys %{$reports})
{
  if ($r =~ /^(.+?)-(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})$/)
  {
    my $dialog = "./dialog.asp?id=delete_report_data&arg1="
      . $Server->URLEncode($report) . "&arg2=$2$3$4-$5:$6&arg3="
      . $Server->URLEncode($r);
    if (($3 ne $month) || ($2 ne $year))
    {
			my $dialog_rm_month = "./dialog.asp?id=delete_report_month&arg1="
				. $Server->URLEncode($report) . "&arg2=$3&arg3=$2";
      ($month, $year) = ($3, $2);
      my $month_name = AAT::Translation(AAT::Datetime::Month_Name($month));
			%><AAT:BoxRow>
			<AAT:BoxCol align="C"><b>--- <%= "$month_name $year" %> ---</b></AAT:BoxCol>
			<AAT:BoxCol cspan="4" align="R"><%
			if (($role !~ /ro/i) && ($role !~ /restricted/i))
			{%>
			<AAT:Button name="remove" tooltip="_REMOVE" 
				popup_link="$dialog_rm_month" /><%
			}%>
			</AAT:BoxCol>
			</AAT:BoxRow><%
		}%>
		<AAT:BoxRow>
			<AAT:BoxCol>
			<% 
			my $ttip = Octopussy::Report::File_Info_Tooltip("$r.info", $lang);
			if (defined $ttip)
				{ %><AAT:Label value="$1 - $2/$3/$4 $5:$6" tooltip="$ttip" /><% }
			else
				{ %><AAT:Label value="$1 - $2/$3/$4 $5:$6" /><% }
			%></AAT:BoxCol>
			<AAT:BoxCol><table><tr><%
			foreach my $ext (sort (AAT::ARRAY($reports->{$r})))
	    {
				if ($ext =~ /rrd$/)
        {
        %><td><AAT:IMG name="mime/bin" tooltip="RRD Data" /></td><%
#          link="./rrd_data_manipulation.asp?report_type=$report&filename=$r.$ext" /></td><%
        }
				elsif (defined $type{$ext})
        {
					my ($mime, $tooltip) = ($type{$ext}{mime}, $type{$ext}{tooltip});
        %><td><AAT:IMG name="mime/$mime" tooltip="$tooltip"
          link="${url_base}&filename=$r.$ext" /></td><%
        }
				elsif ($ext !~ /info$/)
				{
				%><td>
				<AAT:Label value="$ext" link="${url_base}&filename=$r.$ext" /></td><%
				}
			}%>
			</tr></table></AAT:BoxCol><AAT:BoxCol align="C"><%
      if (($role !~ /ro/i) && ($role !~ /restricted/i))
			{
			%><AAT:Button name="remove" tooltip="_REMOVE" popup_link="$dialog" /><%
			}%>
			</AAT:BoxCol>
		</AAT:BoxRow><%	
		$count++;	
	}
}
my $msg = sprintf(AAT::Translation("_MSG_TOTAL_REPORTS"), $count);
%>
<AAT:BoxRow><AAT:BoxCol cspan="5"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="5" align="C">
	<AAT:Label value="$msg" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
