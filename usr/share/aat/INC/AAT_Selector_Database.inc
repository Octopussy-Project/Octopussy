<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @db_types = ( 
	{ label => "MySQL", value => "mysql" },
  { label => "PostgreSQL", value => "Pg" } );

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{name}, list => \@db_types, selected => $arg{selected}); 
%>
