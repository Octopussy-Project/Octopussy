<%
AAT::Syslog::Message("octo_WebUI", "USER_LOGGED_OUT", $Session->{AAT_LOGIN});

my $run_dir = Octopussy::FS::Directory("running");
my $login = $Session->{AAT_LOGIN};
`rm -f $run_dir/logs_${login}_*`;

%{$Session} = ();

$Response->Redirect("./login.asp");
%>
