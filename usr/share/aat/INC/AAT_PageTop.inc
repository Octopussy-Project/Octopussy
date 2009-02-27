<html>
<head>
<meta http-equiv="Pragma" content="no-cache" charset="utf-8">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<% 
my %arg = @_; 
use utf8;

if (defined $arg{icon})
	{ %><link rel="icon" type="image/gif" href="<%= $arg{icon} %>"><% }
if (defined $arg{refresh})
	{ %><meta http-equiv="refresh" content="<%= $arg{refresh} %>"><% }
if ((defined $arg{popup}) && ($arg{popup} =~ /y/i))
	{ %><AAT:JS_Inc file="AAT/INC/AAT_popup.js" /><% }
if ((defined $arg{closepopup}) && ($arg{closepopup} =~ /y/i))
	{ %><AAT:JS_Inc file="AAT/INC/AAT_closepopup.js" /><% } 
if (defined $arg{ofc})
{
  %>
<script type="text/javascript" src="JS/prototype.js"></script>
<script type="text/javascript" src="JS/swfobject.js"></script>
<script type="text/javascript">
swfobject.embedSWF(
  "open-flash-chart.swf", "open_flash_chart", "800", "600",
  "9.0.0", "expressInstall.swf",
  {"data-file":"<%= $arg{ofc} %>"}
  );
</script>
<script type="text/javascript">
OFC = {};

OFC.prototype = {
  name: "Prototype",
  version: function(src) { return $(src).get_version() },
  rasterize: function (src, dst) 
    { $(dst).replace(new Element("img", {src: Control.OFC.image(src)})) },
  image: function(src) 
    { return "data:image/png;base64," + $(src).get_img_binary() },
  popup: function(src) 
  {
    var img_win = window.open('', 'Charts: Export as Image')
    with(img_win.document) {
      write("<html><head><title>Charts: Export as Image<\/title><\/head><body><img src='" + Control.OFC.image(src) + "' /><\/body><\/html>") }
  }
}

if (typeof(Control == "undefined")) {var Control = {OFC: OFC.prototype}}
 
function save_image() { Control.OFC.popup('open_flash_chart') }

</script>
  <%
}
%>
<title><%= $arg{title} %></title>
</head>
<body <%= (defined $arg{onLoad} ? "onLoad=\"$arg{onLoad}\"" : "") %>>
<AAT:PageTheme />
<% 
if ((defined $arg{tooltip}) && ($arg{tooltip} =~ /y/i))
	{ %><AAT:JS_Inc file="AAT/INC/AAT_tooltip.js" /><% }
%>
