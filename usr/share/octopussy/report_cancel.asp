<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_file = $pid_dir . "octo_reporter_${pid_param}.pid";
my $status_file = $pid_dir . "octo_reporter_${pid_param}.status";

$Session->{progress_current} = undef;
$Session->{progress_desc} = undef;
$Session->{progress_running} = undef;
$Session->{progress_total} = undef;

$pid = `cat "$pid_file"`;
kill USR2 => $pid;
$Response->Redirect("./reports.asp");
%>
