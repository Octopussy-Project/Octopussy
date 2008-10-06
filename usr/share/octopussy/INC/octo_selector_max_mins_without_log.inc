<%
my %arg = @_;
my $selected = $arg{selected} || "";
my $mins = AAT::Translation("_MINUTES");
my $hrs = AAT::Translation("_HOURS");

my @mins_without_logs_list = (
	{ label => "", value => "" },
	{ label => "1 " . AAT::Translation("_MINUTE") , value => 1 },
	{ label => "5 $mins" , value => 5 }, { label => "10 $mins", value => 10 },
	{ label => "15 $mins", value => 15 }, { label => "30 $mins", value => 30 }, 
	{ label => "1 " . AAT::Translation("_HOUR") , value => 60 },
	{ label => "2 $hrs" , value => 120 }, { label => "4 $hrs", value => 240 },
	{ label => "6 $hrs", value => 360 }, { label => "12 $hrs", value => 720 },
	{ label => "24 $hrs", value => 1440 } );
%>
<AAT:Selector name="minutes_without_logs"
    list=\@mins_without_logs_list selected="$selected" />
