<%
AAT::Syslog("octo_WebUI", "USER_LOGGED_OUT");
%{$Session} = ();
$Response->Redirect("./login.asp");
%>
