<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<AAT:PageTop title="File Explorer" />
<%
my %arg = @_;

opendir(DIR, $arg{directory});
my @files = readdir(DIR);
closedir(DIR);
%>
<AAT:Box>


<AAT:Box>
<AAT:BoxRow><AAT:BoxCol>
<AAT:Label value="$arg{directory}" style="B" />
</AAT:BoxCol></AAT:BoxRow>
<%
foreach my $file (sort @files)
{
	my $mime_icon = AAT::File::Mime_Icon("$arg{directory}/$file");
	if (NOT_NULL($arg{size}) || NOT_NULL($arg{date}))
	{
		my @stat = stat("$arg{directory}/$file");
		my $size = $stat[7];	
	}
	my $link = (-d "$arg{directory}/$file" ? "demo.asp?directory=" . $Server->URLEncode("$arg{directory}/$file") : "demo2.asp?file=" . $Server->URLEncode("$arg{directory}/$file"));
	%><AAT:BoxRow><AAT:BoxCol>
	<AAT:Picture file="$mime_icon" />
	<AAT:Label value="$file" size="-1" popup_link="$link" />
	</AAT:BoxCol><%
	if (NOT_NULL($arg{size}))
	{%>
		<AAT:BoxCol align="R"><AAT:Label value="$size" />
		</AAT:BoxCol><%
	}%>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
<AAT:PageBottom />
