<%
my %arg = @_;
%>
<AAT:Box align="center">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Picture file="$arg{file}" /></AAT:BoxCol>
<AAT:BoxCol valign="middle"><%
if (AAT::NOT_NULL($arg{zoom}))
{%>
	<AAT:Box>
	<AAT:BoxRow><AAT:BoxCol><AAT:Button name="zoom_in" tooltip="_ZOOM_IN" />
	</AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol><AAT:Button name="zoom_out" tooltip="_ZOOM_OUT" />
	</AAT:BoxCol></AAT:BoxRow>
	</AAT:Box><%
}%>
</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol cspan="2" align="C">
	<AAT:Box align="center">
  <AAT:BoxRow>
	<AAT:BoxCol><AAT:Button name="zoom_in" tooltip="_ROTATE_LEFT" />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Button name="zoom_out" tooltip="_ROTATE_RIGHT" />
	</AAT:BoxCol>
	</AAT:BoxRow>
  </AAT:Box>
</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
