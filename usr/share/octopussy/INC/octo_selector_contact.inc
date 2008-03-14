<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @list = Octopussy::Contact::List();
if ($#list >= 0)
{
	$Response->Include('AAT/INC/AAT_Selector.inc', 
		name => ($arg{name} || "contact"), 
		multiple => (defined $arg{multiple} ? "1" : undef), 
		size => ($arg{size} || 5), list => \@list, selected => $arg{selected});
}
else
{
%><AAT:Message level="1" msg="_MSG_NEED_DEFINE_CONTACT" 
	link="./contacts.asp" /><%
}
%>
