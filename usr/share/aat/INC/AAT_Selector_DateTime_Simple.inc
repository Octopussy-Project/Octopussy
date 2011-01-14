<%
my %arg = @_;
my $name = $arg{name};
my $s_year = $arg{start_year};

my ($c_h1, $c_h2) = AAT::Datetime::Current_Hour();
my ($c_d1, $c_d2) = AAT::Datetime::Current_Day();
my ($c_w1, $c_w2) = AAT::Datetime::Current_Week();
my ($c_m1, $c_m2) = AAT::Datetime::Current_Month();
my ($c_y1, $c_y2) = AAT::Datetime::Current_Year();
my ($l_h1, $l_h2) = AAT::Datetime::Last_Hour();
my ($l_d1, $l_d2) = AAT::Datetime::Last_Day();
my ($l_w1, $l_w2) = AAT::Datetime::Last_Week();
my ($l_m1, $l_m2) = AAT::Datetime::Last_Month();
my ($l_y1, $l_y2) = AAT::Datetime::Last_Year();

my @list = ("_CUSTOMIZED", "_CURRENT_HOUR", "_CURRENT_DAY", 
	"_CURRENT_WEEK", "_CURRENT_MONTH", "_CURRENT_YEAR", 
  "_LAST_HOUR", "_LAST_DAY", "_LAST_WEEK", "_LAST_MONTH", "_LAST_YEAR" );
%>
<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol align="C"><AAT:Button name="scheduler" /></AAT:BoxCol>
  <AAT:BoxCol align="C">
  <select name="<%= $name %>"
    onchange="update_dt_selector(this.options.selectedIndex)">
  <%
  foreach my $e (@list)
  {
    $Response->Include("AAT/INC/AAT_OptionSelector.inc", 
			label => AAT::Translation($e), value => $e, 
			selected => ($arg{selected} eq $e ? "selected" : undef));
  }
  %>
  </select>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
    <AAT:Label value="_BEGIN" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector_DateTime name="${name}1" start_year="$s_year"
  	selected="$arg{selected1}" onchange="custom_dt()" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
    <AAT:Label value="_END" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector_DateTime name="${name}2" start_year="$s_year"
  	selected="$arg{selected2}" onchange="custom_dt()" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<script type="text/javascript">
var len = document.forms[0].<%= $name %>.options.length;
var dts1 = new Array(len);
var dts2 = new Array(len);
for (i = 0; i < len; i++)
{
  dts1[i] = new Array(5);
  dts2[i] = new Array(5);
}

dts1[0]=['<%= $c_h1->{year}-$s_year %>','<%= $c_h1->{month}-1 %>','<%= $c_h1->{day}-1 %>','<%= $c_h1->{hour} %>','<%= $c_h1->{min} %>'];
dts2[0]=['<%= $c_h2->{year}-$s_year %>','<%= $c_h2->{month}-1 %>','<%= $c_h2->{day}-1 %>','<%= $c_h2->{hour} %>','<%= $c_h2->{min} %>'];
dts1[1]=['<%= $c_d1->{year}-$s_year %>','<%= $c_d1->{month}-1 %>','<%= $c_d1->{day}-1 %>','<%= $c_d1->{hour} %>','<%= $c_d1->{min} %>'];
dts2[1]=['<%= $c_d2->{year}-$s_year %>','<%= $c_d2->{month}-1 %>','<%= $c_d2->{day}-1 %>','<%= $c_d2->{hour} %>','<%= $c_d2->{min} %>'];
dts1[2]=['<%= $c_w1->{year}-$s_year %>','<%= $c_w1->{month}-1 %>','<%= $c_w1->{day}-1 %>','<%= $c_w1->{hour} %>','<%= $c_w1->{min} %>'];
dts2[2]=['<%= $c_w2->{year}-$s_year %>','<%= $c_w2->{month}-1 %>','<%= $c_w2->{day}-1 %>','<%= $c_w2->{hour} %>','<%= $c_w2->{min} %>'];
dts1[3]=['<%= $c_m1->{year}-$s_year %>','<%= $c_m1->{month}-1 %>','<%= $c_m1->{day}-1 %>','<%= $c_m1->{hour} %>','<%= $c_m1->{min} %>'];
dts2[3]=['<%= $c_m2->{year}-$s_year %>','<%= $c_m2->{month}-1 %>','<%= $c_m2->{day}-1 %>','<%= $c_m2->{hour} %>','<%= $c_m2->{min} %>'];
dts1[4]=['<%= $c_y1->{year}-$s_year %>','<%= $c_y1->{month}-1 %>','<%= $c_y1->{day}-1 %>','<%= $c_y1->{hour} %>','<%= $c_y1->{min} %>'];
dts2[4]=['<%= $c_y2->{year}-$s_year %>','<%= $c_y2->{month}-1 %>','<%= $c_y2->{day}-1 %>','<%= $c_y2->{hour} %>','<%= $c_y2->{min} %>'];
dts1[5]=['<%= $l_h1->{year}-$s_year %>','<%= $l_h1->{month}-1 %>','<%= $l_h1->{day}-1 %>','<%= $l_h1->{hour} %>','<%= $l_h1->{min} %>'];
dts2[5]=['<%= $l_h2->{year}-$s_year %>','<%= $l_h2->{month}-1 %>','<%= $l_h2->{day}-1 %>','<%= $l_h2->{hour} %>','<%= $l_h2->{min} %>'];
dts1[6]=['<%= $l_d1->{year}-$s_year %>','<%= $l_d1->{month}-1 %>','<%= $l_d1->{day}-1 %>','<%= $l_d1->{hour} %>','<%= $l_d1->{min} %>'];
dts2[6]=['<%= $l_d2->{year}-$s_year %>','<%= $l_d2->{month}-1 %>','<%= $l_d2->{day}-1 %>','<%= $l_d2->{hour} %>','<%= $l_d2->{min} %>'];
dts1[7]=['<%= $l_w1->{year}-$s_year %>','<%= $l_w1->{month}-1 %>','<%= $l_w1->{day}-1 %>','<%= $l_w1->{hour} %>','<%= $l_w1->{min} %>'];
dts2[7]=['<%= $l_w2->{year}-$s_year %>','<%= $l_w2->{month}-1 %>','<%= $l_w2->{day}-1 %>','<%= $l_w2->{hour} %>','<%= $l_w2->{min} %>'];
dts1[8]=['<%= $l_m1->{year}-$s_year %>','<%= $l_m1->{month}-1 %>','<%= $l_m1->{day}-1 %>','<%= $l_m1->{hour} %>','<%= $l_m1->{min} %>'];
dts2[8]=['<%= $l_m2->{year}-$s_year %>','<%= $l_m2->{month}-1 %>','<%= $l_m2->{day}-1 %>','<%= $l_m2->{hour} %>','<%= $l_m2->{min} %>'];
dts1[9]=['<%= $l_y1->{year}-$s_year %>','<%= $l_y1->{month}-1 %>','<%= $l_y1->{day}-1 %>','<%= $l_y1->{hour} %>','<%= $l_y1->{min} %>'];
dts2[9]=['<%= $l_y2->{year}-$s_year %>','<%= $l_y2->{month}-1 %>','<%= $l_y2->{day}-1 %>','<%= $l_y2->{hour} %>','<%= $l_y2->{min} %>'];

function update_dt_selector(x)
{
  x = x-1;
  if (x > -1)
  {
  document.forms[0].dt1_year.options[dts1[x][0]].selected = true;
  document.forms[0].dt1_month.options[dts1[x][1]].selected = true;
  document.forms[0].dt1_day.options[dts1[x][2]].selected = true;
  document.forms[0].dt1_hour.options[dts1[x][3]].selected = true;
  document.forms[0].dt1_min.options[dts1[x][4]].selected = true;
  document.forms[0].dt2_year.options[dts2[x][0]].selected = true;
  document.forms[0].dt2_month.options[dts2[x][1]].selected = true;
  document.forms[0].dt2_day.options[dts2[x][2]].selected = true;
  document.forms[0].dt2_hour.options[dts2[x][3]].selected = true;
  document.forms[0].dt2_min.options[dts2[x][4]].selected = true;
  }
}

function custom_dt()
{
	document.forms[0].<%= $name %>.options[0].selected = true;	
}
</script>
