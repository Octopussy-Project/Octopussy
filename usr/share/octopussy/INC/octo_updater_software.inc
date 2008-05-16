<%
my %arg = @_;

my $sf_link = "http://sourceforge.net/project/showfiles.php?group_id=154314";
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
