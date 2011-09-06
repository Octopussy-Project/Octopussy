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
  <select id="<%= $name %>" name="<%= $name %>"
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
  <AAT:BoxCol><AAT:Selector_DateTime name="${name}1"
  	selected="$arg{selected1}" onchange="custom_dt()" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="R">
    <AAT:Label value="_END" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector_DateTime name="${name}2"
  	selected="$arg{selected2}" onchange="custom_dt()" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<script type="text/javascript">
var len = $('#<%= $name %> option').length;
var dts1 = new Array(len);
var dts2 = new Array(len);
for (i = 0; i < len; i++)
{
  dts1[i] = new Array(3);
  dts2[i] = new Array(3);
}

dts1[0]=['<%= $c_h1->{year} %>-<%= $c_h1->{month} %>-<%= $c_h1->{day} %>','<%= $c_h1->{hour} %>','<%= $c_h1->{min} %>'];
dts2[0]=['<%= $c_h2->{year} %>-<%= $c_h2->{month} %>-<%= $c_h2->{day} %>','<%= $c_h2->{hour} %>','<%= $c_h2->{min} %>'];
dts1[1]=['<%= $c_d1->{year} %>-<%= $c_d1->{month} %>-<%= $c_d1->{day} %>','<%= $c_d1->{hour} %>','<%= $c_d1->{min} %>'];
dts2[1]=['<%= $c_d2->{year} %>-<%= $c_d2->{month} %>-<%= $c_d2->{day} %>','<%= $c_d2->{hour} %>','<%= $c_d2->{min} %>'];
dts1[2]=['<%= $c_w1->{year} %>-<%= $c_w1->{month} %>-<%= $c_w1->{day} %>','<%= $c_w1->{hour} %>','<%= $c_w1->{min} %>'];
dts2[2]=['<%= $c_w2->{year} %>-<%= $c_w2->{month} %>-<%= $c_w2->{day} %>','<%= $c_w2->{hour} %>','<%= $c_w2->{min} %>'];
dts1[3]=['<%= $c_m1->{year} %>-<%= $c_m1->{month} %>-<%= $c_m1->{day} %>','<%= $c_m1->{hour} %>','<%= $c_m1->{min} %>'];
dts2[3]=['<%= $c_m2->{year} %>-<%= $c_m2->{month} %>-<%= $c_m2->{day} %>','<%= $c_m2->{hour} %>','<%= $c_m2->{min} %>'];
dts1[4]=['<%= $c_y1->{year} %>-<%= $c_y1->{month} %>-<%= $c_y1->{day} %>','<%= $c_y1->{hour} %>','<%= $c_y1->{min} %>'];
dts2[4]=['<%= $c_y2->{year} %>-<%= $c_y2->{month} %>-<%= $c_y2->{day} %>','<%= $c_y2->{hour} %>','<%= $c_y2->{min} %>'];
dts1[5]=['<%= $l_h1->{year} %>-<%= $l_h1->{month} %>-<%= $l_h1->{day} %>','<%= $l_h1->{hour} %>','<%= $l_h1->{min} %>'];
dts2[5]=['<%= $l_h2->{year} %>-<%= $l_h2->{month} %>-<%= $l_h2->{day} %>','<%= $l_h2->{hour} %>','<%= $l_h2->{min} %>'];
dts1[6]=['<%= $l_d1->{year} %>-<%= $l_d1->{month} %>-<%= $l_d1->{day} %>','<%= $l_d1->{hour} %>','<%= $l_d1->{min} %>'];
dts2[6]=['<%= $l_d2->{year} %>-<%= $l_d2->{month} %>-<%= $l_d2->{day} %>','<%= $l_d2->{hour} %>','<%= $l_d2->{min} %>'];
dts1[7]=['<%= $l_w1->{year} %>-<%= $l_w1->{month} %>-<%= $l_w1->{day} %>','<%= $l_w1->{hour} %>','<%= $l_w1->{min} %>'];
dts2[7]=['<%= $l_w2->{year} %>-<%= $l_w2->{month} %>-<%= $l_w2->{day} %>','<%= $l_w2->{hour} %>','<%= $l_w2->{min} %>'];
dts1[8]=['<%= $l_m1->{year} %>-<%= $l_m1->{month} %>-<%= $l_m1->{day} %>','<%= $l_m1->{hour} %>','<%= $l_m1->{min} %>'];
dts2[8]=['<%= $l_m2->{year} %>-<%= $l_m2->{month} %>-<%= $l_m2->{day} %>','<%= $l_m2->{hour} %>','<%= $l_m2->{min} %>'];
dts1[9]=['<%= $l_y1->{year} %>-<%= $l_y1->{month} %>-<%= $l_y1->{day} %>','<%= $l_y1->{hour} %>','<%= $l_y1->{min} %>'];
dts2[9]=['<%= $l_y2->{year} %>-<%= $l_y2->{month} %>-<%= $l_y2->{day} %>','<%= $l_y2->{hour} %>','<%= $l_y2->{min} %>'];

function update_dt_selector(x)
{
  x = x-1;
  if (x > -1)
  {
	$('#dt1_date').val(dts1[x][0]);
  	$('#dt1_hour option[value=' + dts1[x][1] + ']').attr('selected', 'selected');
  	$('#dt1_min option[value=' + dts1[x][2] + ']').attr('selected', 'selected');
  	$('#dt2_date').val(dts2[x][0]); 
  	$('#dt2_hour option[value=' + dts2[x][1] + ']').attr('selected', 'selected');
  	$('#dt2_min option[value=' + dts2[x][2] + ']').attr('selected', 'selected');
  }
}

function custom_dt()
{
	$('#<%= $name %> option[value=_CUSTOMIZED]').attr('selected', 'selected');
}
</script>
