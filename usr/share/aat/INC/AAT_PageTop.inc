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
%>
<title><%= $arg{title} %></title>
</head>
<body <%= (defined $arg{onLoad} ? "onLoad=\"$arg{onLoad}\"" : "") %>>
<AAT:PageTheme />
<% 
if ((defined $arg{tooltip}) && ($arg{tooltip} =~ /y/i))
	{ %><AAT:JS_Inc file="AAT/INC/AAT_tooltip.js" /><% }
%>
