<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @list = ( { label => "_YES", value => 1 },
	{ label => "_NO", value => 0 } );

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => "$arg{name}", list => \@list, selected => $arg{selected}); 
%>
