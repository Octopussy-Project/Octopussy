<% 
my %arg = @_; 
my $form_number = $arg{form_number} || 0;
%>
<select name="search_template" 
	onchange="update_search_params(this.options.selectedIndex)">
<%
my $login = $Session->{AAT_LOGIN};
$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "",
	selected => ($arg{selected} eq "" ? "selected" : ""), label => "-NONE-");
foreach my $e (Octopussy::Search_Template::List($login))
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $e,
    selected => ($arg{selected} eq $e ? "selected" : ""), label => $e );
}
%>
</select>
<script type="text/javascript">
var nb_tpl = document.forms[<%= $form_number %>].search_template.options.length;
var tpl = new Array(nb_tpl);
for (i = 0; i < nb_tpl; i++)
  tpl[i] = new Array();
<%
my $i = 1;
foreach my $t (Octopussy::Search_Template::Configurations($login, "name"))
{
	my $dev_str = join(",", AAT::ARRAY($t->{device}));
	my $serv_str = join(",", AAT::ARRAY($t->{service}));
%>
tpl[<%= $i %>].template = '<%= $t->{name} %>';
tpl[<%= $i %>].device = '<%= $dev_str %>';
tpl[<%= $i %>].service = '<%= $serv_str %>';
tpl[<%= $i %>].re_include = '<%= $t->{re_include} %>';
tpl[<%= $i %>].re_include2 = '<%= $t->{re_include2} %>';
tpl[<%= $i %>].re_include3 = '<%= $t->{re_include3} %>';
tpl[<%= $i %>].re_exclude = '<%= $t->{re_exclude} %>';
tpl[<%= $i %>].re_exclude2 = '<%= $t->{re_exclude2} %>';
tpl[<%= $i %>].re_exclude3 = '<%= $t->{re_exclude3} %>';
<%
	$i++;
}
%>

function update_search_params(x)
{
	var form = document.forms[<%= $form_number %>];
	if (x > 0)
	{
		var device_list = tpl[x].device.split(','); 
		var device_index = 0;
		for (i = 0; i < form.device.options.length; i++)
		{
			form.device.options[i].selected = 0;
			for (i2 = 0; i2 < device_list.length; i2++)
			{
				if (form.device.options[i].value == device_list[i2])
				{
					form.device.options[i].selected = 1;
					device_index = i;
				}
			}
		}
		if (device_list.length > 1)
      { update_service(0); }
		else
			{ update_service(device_index); }
		var service_list = tpl[x].service.split(',');
		for (i = 0; i < form.service.options.length; i++)
  	{	
			form.service.options[i].selected = 0;
			for (i2 = 0; i2 < service_list.length; i2++)
      {
    		if (form.service.options[i].value == service_list[i2])
      		form.service.options[i].selected = 1;
			}
  	}
		form.template.value = tpl[x].template;
		form.re_include.value = tpl[x].re_include;
		form.re_include2.value = tpl[x].re_include2;
		form.re_include3.value = tpl[x].re_include3;
		form.re_exclude.value = tpl[x].re_exclude;
  	form.re_exclude2.value = tpl[x].re_exclude2;
		form.re_exclude3.value = tpl[x].re_exclude3;	
	}
}
</script>
