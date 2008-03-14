<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
use Octopussy;

my $cmd = $Request->QueryString("cmd");

my $reportname = $cmd;
$reportname =~ s/.+\/(.+)?"$/$1/g;
my $pid_dir = Octopussy::Directory("running");
my $pid_file = $pid_dir . "octo_reporter_" . $reportname . ".pid";
my $status_file = $pid_dir . "octo_reporter_" . $reportname . ".status";

$pid = `cat "$pid_file"`;
kill KILL => $pid;
unlink("$pid_file");
unlink("$status_file");
$Response->Redirect("./reports.asp");
%>
