<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
AAT::Syslog("octo_WebUI", "USER_LOGGED_OUT");

my $run_dir = Octopussy::Directory("running");
my $login = $Session->{AAT_LOGIN};
`rm -f $run_dir/logs_${login}_*`;

%{$Session} = ();

$Response->Redirect("./login.asp");
%>
