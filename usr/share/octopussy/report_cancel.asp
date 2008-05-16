<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_file = $pid_dir . "octo_reporter_${pid_param}.pid";
my $status_file = $pid_dir . "octo_reporter_${pid_param}.status";

$pid = `cat "$pid_file"`;
kill USR2 => $pid;
$Response->Redirect("./reports.asp");
%>
