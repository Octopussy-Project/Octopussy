<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my @codes = ();

opendir(DIR, "/usr/share/aat/IMG/flags/");
my @list = grep /\.png$/, readdir(DIR);
foreach my $i (sort @list)
{
	push(@codes, uc($1)) if ($i =~ /^(\w{2}).png$/);
}
closedir(DIR);

$Response->Include('AAT/INC/AAT_Selector.inc',
  name => $arg{name} || "country_code", 
	list => \@codes, selected => $arg{selected} || "FR");
%>
