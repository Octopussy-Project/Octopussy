<%
my %arg = @_;
my $name = $arg{name} || "device_model";
my $form_number = $arg{form_number} || 0;
my $device_type = $arg{device_type} || "Unknown";
my @models = Octopussy::Device::Models($device_type);
my @list = ();
foreach my $m (@models)
	{ push(@list, $m->{name}); }
$Response->Include('AAT/INC/AAT_Selector.inc', name => $name, 
	list => \@list, selected => ($arg{selected} || "Unknown"));
%>
<script type="text/javascript">
var dtype = document.forms[<%= $form_number %>].device_type.options.length;
var model = new Array(dtype);
for (i=0; i<dtype; i++)
  model[i] = new Array();
<%
my $i = 0;
my @dts = Octopussy::Device::Types();
foreach my $dt (sort @dts)
{
	my $i2 = 0;
  foreach my $m (Octopussy::Device::Models($dt))
  {
		my $model = $m->{name} ; %>
model[<%= $i %>][<%= $i2++ %>] = new Option("<%=$model%>","<%=$model%>");<%
  }
  $i++;
}
%>
var temp_dm = document.forms[<%= $form_number %>].<%= $name %>;

function update_device_model(x)
{
  for (m=temp_dm.options.length-1; m>0; m--)
    temp_dm.options[m] = null;
  for (i=0; i<model[x].length; i++)
    temp_dm.options[i] = new Option(model[x][i].text,model[x][i].value);
  temp_dm.options[0].selected = true;
}
</script>
