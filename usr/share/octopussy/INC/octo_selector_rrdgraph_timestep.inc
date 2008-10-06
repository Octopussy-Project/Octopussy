<%
my %arg = @_;

my @steps = (
	{ label => "1 " . AAT::Translation("_MINUTE"), value => 1 }, 
	{ label => "5 " . AAT::Translation("_MINUTES"), value => 5 }, 
	{ label => "10 " . AAT::Translation("_MINUTES"), value => 10 },
	{ label => "30 "  . AAT::Translation("_MINUTES"), value => 30 }, 
	{ label => "1 " . AAT::Translation("_HOUR"), value => 60 },
	{ label => "4 " . AAT::Translation("_HOURS"), value => 240 }, 
	{ label => "12 " . AAT::Translation("_HOURS"), value => 720 },
	{ label => "1 " . AAT::Translation("_DAY"), value => 1440 } );

$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => ($arg{name} || "rrd_step"), list => \@steps, 
	selected => $arg{selected});
%>
