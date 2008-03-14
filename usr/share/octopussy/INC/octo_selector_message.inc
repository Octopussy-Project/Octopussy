<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 

my @list = ();
my @services = Octopussy::Service::List();
foreach my $s (@services)
{
  my @msgs = Octopussy::Service::Messages($s);
  foreach my $m (@msgs)
  	{ push(@list, $m->{msg_id}); }
}
$Response->Include('AAT/INC/AAT_Selector.inc',
	name => ($arg{name} || "message"), list => \@list);
%>
