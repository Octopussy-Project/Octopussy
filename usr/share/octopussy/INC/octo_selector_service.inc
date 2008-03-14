<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @services = (defined $arg{any} ? ("-ANY-") : ());
push(@services, (defined $arg{device} 
	? sort(Octopussy::Device::Services($arg{device})) 
	: Octopussy::Service::List()));

$Response->Include('AAT/INC/AAT_Selector.inc', name => ($arg{name} || "service"),
  list => \@services, exclude => $arg{exclude}, selected => $arg{selected});
%>
