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
      var tpl, devices, services, device_list, service_list;
      var loglevel, taxonomy, msgid;
      var re_include, re_include2, re_include3; 
      var re_exclude, re_exclude2, re_exclude3;

      var tempNode = root.getElementsByTagName('template')[0].firstChild;
      if (null != tempNode)
        tpl = tempNode.nodeValue;
      tempNode = root.getElementsByTagName('device')[0].firstChild;
      if (null != tempNode) {
        devices = tempNode.nodeValue;
        device_list = devices.split(',');
      }
      tempNode = root.getElementsByTagName('service')[0].firstChild;
      if (null != tempNode) {
        services = tempNode.nodeValue
        service_list = services.split(','); 
      }
      tempNode = root.getElementsByTagName('loglevel')[0].firstChild;
      if (null != tempNode)
        loglevel = tempNode.nodeValue;
      tempNode = root.getElementsByTagName('taxonomy')[0].firstChild;
      if (null != tempNode)
        taxonomy = tempNode.nodeValue
      tempNode = root.getElementsByTagName('msgid')[0].firstChild;
      if (null != tempNode)
        msgid = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_include')[0].firstChild;
      if (null != tempNode)
        re_include = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_include2')[0].firstChild;
      if (null != tempNode)
        re_include2 = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_include3')[0].firstChild;
      if (null != tempNode)
        re_include3 = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_exclude')[0].firstChild;
      if (null != tempNode)
        re_exclude = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_exclude2')[0].firstChild;
      if (null != tempNode)
        re_exclude2 = tempNode.nodeValue
      tempNode = root.getElementsByTagName('re_exclude3')[0].firstChild;
      if (null != tempNode)
        re_exclude3 = tempNode.nodeValue
      
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
      
      for (i = 0; i < form.service.options.length; i++)
      {  
        form.service.options[i].selected = 0;
        for (i2 = 0; i2 < service_list.length; i2++)
        {
          if (form.service.options[i].value == service_list[i2])
            form.service.options[i].selected = 1;
        }
      }
      for (i = 0; i < form.loglevel.options.length; i++)
      {  
        form.loglevel.options[i].selected = 0;
        if (form.loglevel.options[i].value == loglevel)
          form.loglevel.options[i].selected = 1;
      }
      for (i = 0; i < form.taxonomy.options.length; i++)
      {  
        form.taxonomy.options[i].selected = 0;
        if (form.taxonomy.options[i].value == taxonomy)
          form.taxonomy.options[i].selected = 1;
      }
      for (i = 0; i < form.msgid.options.length; i++)
      {  
        form.msgid.options[i].selected = 0;
        if (form.msgid.options[i].value == msgid)
          form.msgid.options[i].selected = 1;
      }

      if (re_include != null)
        form.re_include.value = re_include;
      else
        form.re_include.value = "";
      if (re_include2 != null)
        form.re_include2.value = re_include2;
      else
        form.re_include2.value = "";
      if (re_include3 != null)
        form.re_include3.value = re_include3;
      else
        form.re_include3.value = "";
      if (re_exclude != null)
        form.re_exclude.value = re_exclude;
      else
        form.re_exclude.value = "";
      if (re_exclude2 != null)
        form.re_exclude2.value = re_exclude2;
      else
        form.re_exclude2.value = "";
      if (re_exclude3 != null)
        form.re_exclude3.value = re_exclude3;
      else
        form.re_exclude3.value = "";
      // Refresh services list
      refresh_selector_service();
    }
  }
}
</script>
