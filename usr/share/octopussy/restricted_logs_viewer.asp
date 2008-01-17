<%
my $MAX_LINES = 5000;
my $url = "./restricted_logs_viewer.asp";
my $nb_lines = 0;

my $restrictions = AAT::User::Restrictions($Session->{AAT_LOGIN});
my @restricted_devices = AAT::ARRAY($restrictions->{device});
my @restricted_services = AAT::ARRAY($restrictions->{service});

my $f = $Request->Form();
my $devs = $Session->{device}; 
my $servs = $Session->{service}; 
my (@devices, @services) = ((),());

if (!ref ($devs))
{
	foreach my $rd (@restricted_devices)
  	{ push(@devices, $devs) if ($rd eq $devs); }
	@devices = @restricted_devices  if ($devs eq "-ANY-");  
}
else
{
  foreach my $d (AAT::ARRAY($devs))
  {
		foreach my $rd (@restricted_devices)
    { push(@devices, $d) if ($rd eq $d); }
	}
}

if (!ref ($servs))
{ 
	foreach my $rs (@restricted_services)
		{ push(@services, $servs)	if ($rs eq $servs); }
	@services = @restricted_services	if ($servs eq "-ANY-");
}
else
{
  foreach my $s (AAT::ARRAY($servs))
  {
		foreach my $rs (@restricted_services)
  		{ push(@services, $s) if ($rs eq $s); }
	}
}

my $d1 = $Session->{dt1_day};
my $m1 = $Session->{dt1_month};
my $y1 = $Session->{dt1_year};
my ($hour1, $min1) = ($Session->{dt1_hour}, $Session->{dt1_min});
my $d2 = $Session->{dt2_day};
my $m2 = $Session->{dt2_month};
my $y2 = $Session->{dt2_year};
my ($hour2, $min2) = ($Session->{dt2_hour}, $Session->{dt2_min});
my $regexp_include = $f->{regexp_include};
my $regexp_exclude = $f->{regexp_exclude};
my $regexp_include2 = $f->{regexp_include2};
my $regexp_exclude2 = $f->{regexp_exclude2};

my $text = "";
if (((defined $f->{logs}) || (defined $f->{file})	|| (defined $f->{csv})) 
	&& (($#devices >= 0) && ($#services >= 0) 
			&& ($devices[0] ne "") && ($services[0] ne "")))
{
  my %start = ( year => $y1, month => $m1, day => $d1,
    hour => $hour1, min => $min1 );
  my %finish = ( year => $y2, month => $m2, day => $d2,
    hour => $hour2, min => $min2 );

  my $logs = Octopussy::Logs::Get(\@devices, \@services, \%start, \%finish,
    [$regexp_include, $regexp_include2], [$regexp_exclude, $regexp_exclude2], 
		$MAX_LINES);

	if (defined $f->{file})
	{
		foreach my $l (@{$logs})
      { $text .= "$l" }
		$Response->{ContentType} = "text/txt";
		$Response->AddHeader('Content-Disposition', "filename=\"logs.txt\"");
		print $text;
		$Response->End();
	}
	elsif (defined $f->{csv})
	{
  	foreach my $l (@{$logs})
  	{
    	$text .= "$1;$2;$3\n" 
				if ($l =~ /^(\w{3} \s?\d{1,2} \d\d:\d\d:\d\d) (\S+) (.+)$/);
  	}
  	$Response->{ContentType} = "text/csv";
		$Response->AddHeader('Content-Disposition', "filename=\"logs.csv\"");
  	print $text;
		$Response->End();
	}
	else
	{
		foreach my $l (@{$logs})
    { 
			$text .= $l;
			$nb_lines++;
		}
	}
}
($Session->{logs}, $Session->{file}, $Session->{csv}, $Session->{zip}) =
	(undef, undef, undef, undef);
my $txt_area = $Server->HTMLEncode($text);
%>
<WebUI:PageTopRestricted title="Restricted Logs Viewer" />

<AAT:Form action="$url">
<AAT:Box align="center">
<AAT:BoxRow><AAT:BoxCol align="C" cspan="4">
  <AAT:Label value="_LOGS_VIEWER" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol align="C" cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="center" cspan="4">
  <AAT:Box align="center" width="100%">
  <AAT:BoxRow>
  <AAT:BoxCol align="right">
  <AAT:Label value="_DEVICE" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
    multiple="1" size="5" 
		selected=\@devices restricted_devices=\@restricted_devices /></AAT:BoxCol>
  <AAT:BoxCol align="right">
  <AAT:Label value="_SERVICE" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
    multiple="1" size="5" device=\@devices 
		selected=\@services restricted_services=\@restricted_services />
	</AAT:BoxCol>
  </AAT:BoxRow>
  </AAT:Box>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="center" cspan="4">
  <AAT:Selector_DateTime_Simple name="dt" start_year="2000" url="$url"
    selected1="$d1/$m1/$y1/$hour1/$min1" selected2="$d2/$m2/$y2/$hour2/$min2" />  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="right">
    <AAT:Label value="Regexp (include)" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="regexp_include" value="$regexp_include" size="40" />
  </AAT:BoxCol>
  <AAT:BoxCol align="right">
    <AAT:Label value="Regexp (exclude)" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="regexp_exclude" value="$regexp_exclude" size="40" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="right">
    <AAT:Label value="Regexp (include)" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="regexp_include2" value="$regexp_include2" size="40" />
  </AAT:BoxCol>
  <AAT:BoxCol align="right">
    <AAT:Label value="Regexp (exclude)" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
    <AAT:Entry name="regexp_exclude2" value="$regexp_exclude2" size="40" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="center" cspan="2">
  <AAT:Form_Submit name="logs" value="_GET_LOGS" /></AAT:BoxCol>
  <AAT:BoxCol align="center">
  <AAT:Form_Submit name="file" value="_DOWNLOAD_FILE" /></AAT:BoxCol>
  <AAT:BoxCol align="center">
  <AAT:Form_Submit name="csv" value="_DOWNLOAD_CSV_FILE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="4">
  <AAT:TextArea name="logs" cols="120" rows="25" wrap="off" data="$txt_area" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="4" align="C">
<%if ($nb_lines<$MAX_LINES)
{
	my $str = sprintf(AAT::Translation("_MSG_NB_LINES"), $nb_lines);
%><AAT:Label value="$str" style="B"/><%
}
else
{
	my $str = sprintf(AAT::Translation("_MSG_REACH_MAX_LINES"), $MAX_LINES);
%><AAT:Message level="1" msg="$str" /><%
}
%></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
<WebUI:PageBottom />
