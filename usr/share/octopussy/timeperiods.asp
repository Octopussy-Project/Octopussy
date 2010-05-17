<WebUI:PageTop title="_TIMEPERIODS" help="#timeperiods_page" />
<%
my $timeperiod = $Request->QueryString("timeperiod");
my $action = $Request->QueryString("action");
if ((defined $timeperiod) && ($action eq "remove"))
{
	Octopussy::TimePeriod::Remove($timeperiod);
	AAT::Syslog("octo_WebUI", "GENERIC_DELETED", "Timeperiod", $timeperiod);
}

my $f = $Request->Form();
if (NOT_NULL($f->{name}))
{
	my @dts = ();

	for my $i (1..7)
	{
		my $d = AAT::Translation(AAT::Datetime::WeekDay_Name($i));
		my $start_h = "${d}_start_hour";
		my $start_m = "${d}_start_min";
		my $finish_h = "${d}_finish_hour";
    my $finish_m = "${d}_finish_min";
		my $negate = "${d}_Negate";
		push(@dts, { $d => ($f->{$negate} eq "on" ? "!" : "")
			. "$f->{$start_h}:$f->{$start_m}"
			. "-$f->{$finish_h}:$f->{$finish_m}" } );
	}
	Octopussy::TimePeriod::New({ label => $f->{name}, dt => \@dts });
	AAT::Syslog("octo_WebUI", "GENERIC_CREATED", "Timeperiod", $f->{name});
}
%>
<AAT:Inc file="octo_timeperiods_list" url="./timeperiods.asp" />
<AAT:Inc file="octo_timeperiod_creator" url="./timeperiods.asp" />
<WebUI:PageBottom />
