<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;
my $name = $arg{name} || "multi_device";
my @devices = Octopussy::Device::List();

$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	multiple => 1, size => 3, list => \@devices);
%>
