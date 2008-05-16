<% my %arg = @_; %>
<AAT:Box align="C" title="Report Errors" width="800">
<%
open(FILE, "< $arg{file}");
while(<FILE>)
{
  if ($_ =~ /^(.+) at (.+) line (\d+).$/)
  {
    my ($error, $file, $line) = ($1, $2, $3);
		%>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="File: $file" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="Line: $line" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"><AAT:Label value="$error" color="red" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow><%
	}
  else
  { %>
<AAT:BoxRow>
  <AAT:BoxCol cspan="2"><AAT:Label value="$error" color="red" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow><%
  }
}
close(FILE);
%>
<AAT:BoxRow>
  <AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="Back to Reports" link="./reports.asp" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
