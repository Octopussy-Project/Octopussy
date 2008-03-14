<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

if (defined $arg{credits})
{
	my $footer = "Apache::ASP Toolkit " . AAT::Version();
	my $link = AAT::WebSite();
	%><div align="center">
	<AAT:Label value="Powered by " size="-2" />
	<AAT:Label value="$footer" size="-2" link="$link" /></div><%
}
%>
</body>
</html>
