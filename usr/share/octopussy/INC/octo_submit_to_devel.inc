<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my @list = ();
my $smtp_conf = AAT::SMTP::Configuration("Octopussy");
foreach my $s (Octopussy::Service::List())
{
  push(@list, { label => "SERVICE $s",
    value => Octopussy::Service::Filename($s) });
}
foreach my $t (Octopussy::Table::List())
{
  push(@list, { label => "TABLE $t",
    value => Octopussy::Table::Filename($t) });
}

if (AAT::NOT_NULL($smtp_conf->{server}))
{
%>
<AAT:Form method="POST" action="./submit.asp">
<AAT:Box align="center">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_EMAIL" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Entry name="from" size="80" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_SUBJECT" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_MSG_THIS_IS_MY_NEW" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_FILE" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Selector name="file" list=\@list /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
<AAT:BoxCol><AAT:Label value="_COMMENT" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:TextArea name="comment" cols="80" rows="10" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="2" align="center">
<AAT:Form_Submit value="_MSG_SEND_MY_NEW" />
</AAT:BoxCol></AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<%
}
else
{
  %><div align="center">
	<AAT:Label value="_SMTP_SERVER_TO_SUBMIT" link="./system.asp" />
	</div><%
}
%>
