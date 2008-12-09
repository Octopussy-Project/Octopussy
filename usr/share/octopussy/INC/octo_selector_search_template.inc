<% 
my %arg = @_; 
my $form_number = $arg{form_number} || 0;
%>
<select name="search_template" 
	onchange="update_search_params(this.options[this.selectedIndex].value)">
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
<AAT:JS_Inc file="AAT/INC/AAT_ajax.js" />
<script type="text/javascript">
var http_request_tpl = false;

function update_search_params(tpl)
{
	http_request_tpl = HttpRequest();
  if (!http_request_service)
    { return false; }
  http_request_tpl.onreadystatechange = print_search_params;
  http_request_tpl.open('GET', "ajax_list_searchtemplate.asp?"
    + "template=" + tpl, true);
  http_request_tpl.send(null); 
 
  return true;
}

function print_search_params()
{
	if (http_request_tpl.readyState == 4)
  {
    if (http_request_tpl.status == 200)
    {
			var form = document.forms[<%= $form_number %>];
      var xml =  http_request_tpl.responseXML;
      var root = xml.documentElement;
			var tpl = root.getElementsByTagName('template')[0].firstChild.data;
			var devices = root.getElementsByTagName('device')[0].firstChild.data;
			var services = root.getElementsByTagName('service')[0].firstChild.data;			
			var re_include = root.getElementsByTagName('re_include')[0];
			var re_include2 = root.getElementsByTagName('re_include2')[0];
			var re_include3 = root.getElementsByTagName('re_include3')[0];
			var re_exclude = root.getElementsByTagName('re_exclude')[0];
      var re_exclude2 = root.getElementsByTagName('re_exclude2')[0];
      var re_exclude3 = root.getElementsByTagName('re_exclude3')[0];
			var device_list = devices.split(',');
			var service_list = services.split(',');

			form.template.value = tpl;
    	for (i = 0; i < form.device.options.length; i++)
    	{
      	form.device.options[i].selected = 0;
      	for (i2 = 0; i2 < device_list.length; i2++)
      	{
        	if (form.device.options[i].value == device_list[i2])
        		form.device.options[i].selected = 1;
      	}
    	}
			refresh_selector_service();

			if (re_include.firstChild != null)
        form.re_include.value = re_include.firstChild.data
      else
        form.re_include.value = "";
			if (re_include2.firstChild != null)
				form.re_include2.value = re_include2.firstChild.data
			else
    		form.re_include2.value = "";
			if (re_include3.firstChild != null)
    		form.re_include3.value = re_include3.firstChild.data;
			else
				form.re_include3.value = "";
			if (re_exclude.firstChild != null)
        form.re_exclude.value = re_exclude.firstChild.data
      else
        form.re_exclude.value = "";
      if (re_exclude2.firstChild != null)
        form.re_exclude2.value = re_exclude2.firstChild.data
      else
        form.re_exclude2.value = "";
      if (re_exclude3.firstChild != null)
        form.re_exclude3.value = re_exclude3.firstChild.data;
      else
        form.re_exclude3.value = "";

			for (i = 0; i < form.service.options.length; i++)
      {  
        form.service.options[i].selected = 0;
        for (i2 = 0; i2 < service_list.length; i2++)
       {
          if (form.service.options[i].value == service_list[i2])
            form.service.options[i].selected = 1;
        }
      }
		}
	}
}
</script>
