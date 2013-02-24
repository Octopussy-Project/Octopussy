<%
my %arg = @_;

my $sf_link = "http://sourceforge.net/projects/syslog-analyzer/files/";
my $version = Octopussy::Version();
my $sf_version = Octopussy::Sourceforge_Version();

if ((defined $sf_version) && ($version !~ $sf_version))
{
	my $msg = AAT::Translation("_NEW_OCTOPUSSY_VERSION_AVAILABLE") 
		. " ($sf_version) !";
%><AAT:Box align="C">
	<AAT:BoxRow>
	<AAT:BoxCol><AAT:Picture file="IMG/octopussy.gif" width="64" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$msg" link_new="$sf_link" /></AAT:BoxCol>
	</AAT:BoxRow>
</AAT:Box><%
}
%>
