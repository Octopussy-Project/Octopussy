<%
my %arg = @_;

my $mime_icon = AAT::File::Mime_Icon($arg{file}, "BIG");
%>
<AAT:PageTop />
<AAT:Box align="center">
<AAT:BoxRow><AAT:BoxCol rspan="3">
<AAT:Picture file="$mime_icon" />
</AAT:BoxCol>
<AAT:BoxCol>
<AAT:Label value="$arg{file}" style="B" size="+1" />
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
<AAT:PageBottom />
