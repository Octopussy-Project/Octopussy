<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<AAT:Box>
<%
my %arg = @_;

my $conf = AAT::XML::Read("OBJECTS/$arg{object}.xml");
%>
<AAT:Form_Begin method="POST" action="$arg{action}" />
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="2">
	<AAT:Label value="$arg{object} Edition" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $f (AAT::ARRAY($conf->{field}))
{
	my $label = $f->{label};
	my $name = $f->{fid};
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$label" /></AAT:BoxCol>
	<AAT:BoxCol><%
	if ($f->{type} eq "BIRTHDATE")
	{
		%><AAT:Selector_Date name="$name" start_year="1920" /><%
	}
	elsif ($f->{type} eq "DATETIME")
	{
		%><AAT:Selector_DateTime name="$name" /><%
	}
	elsif ($f->{type} eq "BIG_STRING")
	{
		%><AAT:TextArea name="$name" cols="40" rows="5"/><%
	}
	else
	{
		%><AAT:Entry name="$name" size="40"/><%
	}
	%></AAT:BoxCol></AAT:BoxRow><%
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow style="box">
<AAT:BoxCol align="center" cspan="2">
<AAT:Form_Submit value="_SAVE" />
<AAT:Form_End /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
