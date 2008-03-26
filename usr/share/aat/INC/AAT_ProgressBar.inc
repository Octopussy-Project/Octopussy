<%
my %arg = @_;

my $title = $arg{title} || "ProgressBar";
my $msg = $arg{msg};
my $desc = $arg{desc} || "File ";
my $BARS = $arg{bars} || 40;
my $current = $arg{current};
my $total = $arg{total};
if (AAT::NOT_NULL($total))
{
	my $cancel = $arg{cancel};
	my $cbars = $current * $BARS / $total;
	my $percent = int($current*100/$total);

	my $str_bar = "<table border=1 bgcolor=#E7E7E7><tr>";
	foreach my $i (1..$cbars)
	{ 
		my $color = 99 - ($i*50/$BARS);
		$str_bar .= "<td width=10 height=20 bgcolor=\"rgb(0,0,$color)\"></td>";
	} 
	foreach my $i ($cbars+1..$BARS)
		{ $str_bar .= "<td width=10 height=20 bgcolor=\"white\"></td>"; }
	$str_bar .= "</tr></table>";
}
%>
<AAT:Box>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><AAT:Label value="$title" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$msg" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><div id="progressbar_desc"></div></AAT:BoxCol> 
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><div id="progressbar_progress"></div></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C"><div id="progressbar_bar"></div></AAT:BoxCol>
</AAT:BoxRow>
<%
if (defined $arg{cancel})
{
	%><AAT:Form method="POST" action="$arg{cancel}">
	<AAT:BoxRow><AAT:BoxCol><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol align="C"><AAT:Form_Submit value="_CANCEL" /></AAT:BoxCol>
	</AAT:BoxRow></AAT:Form><%
}
%>
</AAT:Box>
