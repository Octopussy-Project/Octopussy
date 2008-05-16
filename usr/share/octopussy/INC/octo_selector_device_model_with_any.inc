<%
my %arg = @_;
my $name = $arg{name} || "device_model";
my $form_number = $arg{form_number} || 0;
my $str_any = AAT::Translation("-ANY-");
my $device_type = $arg{device_type} || "Unknown";
my @models = Octopussy::Device::Models($device_type);
my @list = ("-ANY-");
foreach my $m (@models)
	{ push(@list, $m->{name}); }
$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@list, selected => ($arg{selected} || "Unknown"));
%>
<script type="text/javascript">
var dtype = document.forms[<%= $form_number %>].device_type.options.length;
var model_any = new Array(dtype);
for (i=0; i<dtype; i++)
  model_any[i] = new Array();
model_any[0][0] = new Option("<%= $str_any %>", "-ANY-");
<%
my $i = 1;
my @dts = Octopussy::Device::Types();
foreach my $dt (sort @dts)
{
	my $i2 = 0; %>
model_any[<%= $i %>][<%= $i2++ %>] = new Option("<%= $str_any %>", "-ANY-");<%
  foreach my $m (Octopussy::Device::Models($dt))
  {%>
model_any[<%= $i %>][<%= $i2 %>] = new Option("<%= $m->{name} %>","<%= $m->{name} %>");<%
  	$i2++;
  }
  $i++;
}
%>
var temp_dm_any = document.forms[<%= $form_number %>].<%= $name %>;

function update_device_model_any(x)
{
  for (m=temp_dm_any.options.length-1; m>0; m--)
    temp_dm_any.options[m] = null;
  for (i=0; i<model_any[x].length; i++)
    temp_dm_any.options[i] = new Option(model_any[x][i].text,model_any[x][i].value);
  temp_dm_any.options[0].selected = true;
}
</script>
