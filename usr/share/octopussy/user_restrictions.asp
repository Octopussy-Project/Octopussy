<WebUI:PageTop title="User Restrictions" />
<%
my $url = "./user_restrictions.asp";
my $f = $Request->Form();
my $user = $Request->QueryString("user");

my $restricts = AAT::User::Restrictions("Octopussy", $user);

my @devices_sel = AAT::ARRAY($f->{device} || $Request->QueryString("device")
  || $restricts->{device} || "-ANY-");
my @services_sel = AAT::ARRAY($f->{service} || $Request->QueryString("service")
  || $restricts->{service} || "-ANY-");
my @alerts_sel = AAT::ARRAY($f->{alert} || $restricts->{alert} || "-ANY-");
my @reports_sel = AAT::ARRAY($f->{report} || $restricts->{report} || "-ANY-");

my @alerts = ("-ANY-");
push(@alerts, Octopussy::Alert::List());
my @reports = ("-ANY-");
push(@reports, Octopussy::Report::List(undef, undef));

if ($Session->{AAT_ROLE} =~ /admin/i)
{
	if (AAT::NOT_NULL($f->{submit}))
	{
  	my $conf = { device => \@devices_sel, service => \@services_sel,
			alert => \@alerts_sel, report => \@reports_sel };
		AAT::User::Update_Restrictions("Octopussy", $user, $conf);
	}
%>
<AAT:Form action="$url?user=$user">
<AAT:Box align="C" icon="buttons/bt_users" title="_USER_RESTRICTIONS">
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Button name="device" />
	<AAT:Label value="_DEVICES" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="service" />
	<AAT:Label value="_SERVICES" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="alert" />
	<AAT:Label value="_ALERTS" style="B" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="report" />
	<AAT:Label value="_REPORTS" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Inc file="octo_selector_device_and_devicegroup_dynamic"
    url="$url?user=$user&device=" multiple="1" size="20" 
		selected=\@devices_sel />
	</AAT:BoxCol>
  <AAT:BoxCol><AAT:Inc file="octo_selector_service_dynamic"
    url="$url?user=$user&device=$device&service=" multiple="1" size="20"
    device=\@devices_sel selected=\@services_sel />
	</AAT:BoxCol>
	<AAT:BoxCol>
		<AAT:Selector name="alert" multiple="1" size="20"
			list=\@alerts selected=\@alerts_sel />
  </AAT:BoxCol>
	<AAT:BoxCol>
    <AAT:Selector name="report" multiple="1" size="20"
			list=\@reports selected=\@reports_sel />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="4"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol align="C" cspan="4">
  <AAT:Form_Submit name="submit" 
		value="Apply these restrictions to user $user" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form><%
}
%>
<WebUI:PageBottom />
