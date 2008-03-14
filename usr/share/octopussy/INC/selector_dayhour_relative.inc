<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my $d_selected = $arg{day_selected};
my $h_selected = $arg{hour_selected};
my @d_list = ();
my @h_list = ();
foreach my $n (0..31)
{
	push(@d_list, { label => AAT::Translation("_DAY") . "-$n", 
		value => "Day-$n" });
}
foreach my $n (0..23)
{
	push(@h_list, { label => AAT::Translation("_HOUR") . "-$n",
		value => "Hour-$n" });
}

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{day_name}, list => \@d_list, selected => $d_selected);
$Response->Include('AAT/INC/AAT_Selector.inc',
  name => $arg{hour_name}, list => \@h_list, selected => $h_selected);
%>
