<%
my %arg = @_;
my $name = $arg{name};
my $start_year = $arg{start_year};

my ($cur_hour1, $cur_hour2) = AAT::Datetime::Current_Hour();
my ($cur_day1, $cur_day2) = AAT::Datetime::Current_Day();
my ($cur_week1, $cur_week2) = AAT::Datetime::Current_Week();
my ($cur_month1, $cur_month2) = AAT::Datetime::Current_Month();
my ($cur_year1, $cur_year2) = AAT::Datetime::Current_Year();
my ($last_hour1, $last_hour2) = AAT::Datetime::Last_Hour();
my ($last_day1, $last_day2) = AAT::Datetime::Last_Day();
my ($last_week1, $last_week2) = AAT::Datetime::Last_Week();
my ($last_month1, $last_month2) = AAT::Datetime::Last_Month();
my ($last_year1, $last_year2) = AAT::Datetime::Last_Year();

my @list = ("_CUSTOMIZED", 
	"_CURRENT_HOUR", "_CURRENT_DAY", "_CURRENT_WEEK", 
	"_CURRENT_MONTH", "_CURRENT_YEAR", 
  "_LAST_HOUR", "_LAST_DAY", "_LAST_WEEK", "_LAST_MONTH", "_LAST_YEAR" );
%>
<AAT:Box align="C">
<AAT:BoxRow>
  <AAT:BoxCol>
  </AAT:BoxCol>
  <AAT:BoxCol align="L">
  <select name="<%= $name %>"
    onchange="update_dt_selector(this.options.selectedIndex)">
  <%
  foreach my $e (@list)
  {
    $Response->Include("AAT/INC/AAT_OptionSelector.inc", 
			label => $e, value => $e, 
			selected => ($arg{selected} eq $e ? "selected" : undef));
  }
  %>
  </select>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="right">
    <AAT:Label value="_BEGIN" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Selector_DateTime name="${name}1" start_year="$start_year"
  	selected="$arg{selected1}" />
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol align="right">
    <AAT:Label value="_END" align="right" style="B" /></AAT:BoxCol>
  <AAT:BoxCol>
	<AAT:Selector_DateTime name="${name}2" start_year="$start_year"
  	selected="$arg{selected2}" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

<script type="text/javascript">
var len=document.forms[0].<%= $name %>.options.length;
var dts1=new Array(len);
var dts2=new Array(len);
for (i=0; i<len; i++)
{
  dts1[i]=new Array(5);
  dts2[i]=new Array(5);
}

dts1[0]=['<%= $cur_hour1->{year}-$start_year %>','<%= $cur_hour1->{month}-1 %>','<%= $cur_hour1->{day}-1 %>','<%= $cur_hour1->{hour} %>','<%= $cur_hour1->{min} %>'];
dts2[0]=['<%= $cur_hour2->{year}-$start_year %>','<%= $cur_hour2->{month}-1 %>','<%= $cur_hour2->{day}-1 %>','<%= $cur_hour2->{hour} %>','<%= $cur_hour2->{min} %>'];
dts1[1]=['<%= $cur_day1->{year}-$start_year %>','<%= $cur_day1->{month}-1 %>','<%= $cur_day1->{day}-1 %>','<%= $cur_day1->{hour} %>','<%= $cur_day1->{min} %>'];
dts2[1]=['<%= $cur_day2->{year}-$start_year %>','<%= $cur_day2->{month}-1 %>','<%= $cur_day2->{day}-1 %>','<%= $cur_day2->{hour} %>','<%= $cur_day2->{min} %>'];
dts1[2]=['<%= $cur_week1->{year}-$start_year %>','<%= $cur_week1->{month}-1 %>','<%= $cur_week1->{day}-1 %>','<%= $cur_week1->{hour} %>','<%= $cur_week1->{min} %>'];
dts2[2]=['<%= $cur_week2->{year}-$start_year %>','<%= $cur_week2->{month}-1 %>','<%= $cur_week2->{day}-1 %>','<%= $cur_week2->{hour} %>','<%= $cur_week2->{min} %>'];
dts1[3]=['<%= $cur_month1->{year}-$start_year %>','<%= $cur_month1->{month}-1 %>','<%= $cur_month1->{day}-1 %>','<%= $cur_month1->{hour} %>','<%= $cur_month1->{min} %>'];
dts2[3]=['<%= $cur_month2->{year}-$start_year %>','<%= $cur_month2->{month}-1 %>','<%= $cur_month2->{day}-1 %>','<%= $cur_month2->{hour} %>','<%= $cur_month2->{min} %>'];
dts1[4]=['<%= $cur_year1->{year}-$start_year %>','<%= $cur_year1->{month}-1 %>','<%= $cur_year1->{day}-1 %>','<%= $cur_year1->{hour} %>','<%= $cur_year1->{min} %>'];
dts2[4]=['<%= $cur_year2->{year}-$start_year %>','<%= $cur_year2->{month}-1 %>','<%= $cur_year2->{day}-1 %>','<%= $cur_year2->{hour} %>','<%= $cur_year2->{min} %>'];
dts1[5]=['<%= $last_hour1->{year}-$start_year %>','<%= $last_hour1->{month}-1 %>','<%= $last_hour1->{day}-1 %>','<%= $last_hour1->{hour} %>','<%= $last_hour1->{min} %>'];
dts2[5]=['<%= $last_hour2->{year}-$start_year %>','<%= $last_hour2->{month}-1 %>','<%= $last_hour2->{day}-1 %>','<%= $last_hour2->{hour} %>','<%= $last_hour2->{min} %>'];
dts1[6]=['<%= $last_day1->{year}-$start_year %>','<%= $last_day1->{month}-1 %>','<%= $last_day1->{day}-1 %>','<%= $last_day1->{hour} %>','<%= $last_day1->{min} %>'];
dts2[6]=['<%= $last_day2->{year}-$start_year %>','<%= $last_day2->{month}-1 %>','<%= $last_day2->{day}-1 %>','<%= $last_day2->{hour} %>','<%= $last_day2->{min} %>'];
dts1[7]=['<%= $last_week1->{year}-$start_year %>','<%= $last_week1->{month}-1 %>','<%= $last_week1->{day}-1 %>','<%= $last_week1->{hour} %>','<%= $last_week1->{min} %>'];
dts2[7]=['<%= $last_week2->{year}-$start_year %>','<%= $last_week2->{month}-1 %>','<%= $last_week2->{day}-1 %>','<%= $last_week2->{hour} %>','<%= $last_week2->{min} %>'];
dts1[8]=['<%= $last_month1->{year}-$start_year %>','<%= $last_month1->{month}-1 %>','<%= $last_month1->{day}-1 %>','<%= $last_month1->{hour} %>','<%= $last_month1->{min} %>'];
dts2[8]=['<%= $last_month2->{year}-$start_year %>','<%= $last_month2->{month}-1 %>','<%= $last_month2->{day}-1 %>','<%= $last_month2->{hour} %>','<%= $last_month2->{min} %>'];
dts1[9]=['<%= $last_year1->{year}-$start_year %>','<%= $last_year1->{month}-1 %>','<%= $last_year1->{day}-1 %>','<%= $last_year1->{hour} %>','<%= $last_year1->{min} %>'];
dts2[9]=['<%= $last_year2->{year}-$start_year %>','<%= $last_year2->{month}-1 %>','<%= $last_year2->{day}-1 %>','<%= $last_year2->{hour} %>','<%= $last_year2->{min} %>'];

function update_dt_selector(x)
{
  x=x-1;
  if (x>-1)
  {
  document.forms[0].dt1_year.options[dts1[x][0]].selected=true;
  document.forms[0].dt1_month.options[dts1[x][1]].selected=true;
  document.forms[0].dt1_day.options[dts1[x][2]].selected=true;
  document.forms[0].dt1_hour.options[dts1[x][3]].selected=true;
  document.forms[0].dt1_min.options[dts1[x][4]].selected=true;
  document.forms[0].dt2_year.options[dts2[x][0]].selected=true;
  document.forms[0].dt2_month.options[dts2[x][1]].selected=true;
  document.forms[0].dt2_day.options[dts2[x][2]].selected=true;
  document.forms[0].dt2_hour.options[dts2[x][3]].selected=true;
  document.forms[0].dt2_min.options[dts2[x][4]].selected=true;
  }
}
</script>
