#
# Package: Octopussy::Plugin::CA_BAM_Synergie
#
package Octopussy::Plugin::CA_BAM_Synergie;

use strict;

use Octopussy;

my @list = ();

#
# Function: Init()
#
sub Init
{
	my $bam_conf = AAT::List::Configuration("CA_BAM_Synergie");
	
	foreach my $i (AAT::ARRAY($bam_conf->{item}))
  {
		push(@list, { label => $i->{label}, category => $i->{category}, 
			re => $i->{re} }) if (AAT::NOT_NULL($i->{label}));
	}
}

#
#
#
sub Action
{
	my $url = shift;

	foreach my $a (@list)
	{
		return ($a->{label})	if ($url =~ /^$a->{re}$/)
	}	

	return ("Autre");
	#return ($url);
}

#
#
#
sub Categorie
{
	my $url = shift;

  foreach my $c (@list)
  {
    return ($c->{category})  if ($url =~ /^$c->{re}$/)
  }

  return ("Autre");
  #return ($url);
}

#
#
#
sub Partenaire
{
	my $url = shift;

  foreach my $c (@list)
  {
    return ($c->{label})  
			if (($url =~ /^$c->{re}$/) && ($c->{category} =~ /^Partenaires$/));
  }
	
  return (undef);
}

1;
