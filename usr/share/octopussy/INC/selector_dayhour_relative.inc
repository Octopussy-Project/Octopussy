<% 
my %arg = @_; 
my $d_selected = $arg{day_selected};
my $h_selected = $arg{hour_selected};
my $day_str = AAT::Translation("_DAY");
my $hour_str = AAT::Translation("_HOUR");
my @d_list = ();
my @h_list = ();
foreach my $n (0..31)
	{ push(@d_list, { label => "$day_str-$n", value => "Day-$n" }); }
foreach my $n (0..23)
	{ push(@h_list, { label => "$hour_str-$n", value => "Hour-$n" }); }

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => $arg{day_name}, list => \@d_list, selected => $d_selected);
$Response->Include('AAT/INC/AAT_Selector.inc',
  name => $arg{hour_name}, list => \@h_list, selected => $h_selected);
%>
