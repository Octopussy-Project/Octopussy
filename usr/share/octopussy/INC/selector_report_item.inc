<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @items = ("-NULL-", "Report Author", "Report Date", "Report Page", 
	"Report Title");

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => ($arg{name} || "report_item"), list => \@items);
%>
