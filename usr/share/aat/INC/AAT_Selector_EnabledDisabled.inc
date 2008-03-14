<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @list = ( { label => "_ENABLED", value => "Enabled" },
	{ label => "_DISABLED", value => "Disabled" } );

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => "$arg{name}", list => \@list, selected => $arg{selected}); 
%>
