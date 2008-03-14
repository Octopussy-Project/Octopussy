<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @list = ("-ANY-");
push(@list, Octopussy::TimePeriod::List());

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "timeperiod"),
  list => \@list, selected => $arg{selected});
%>
