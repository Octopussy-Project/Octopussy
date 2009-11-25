<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_param = $Session->{progress_running};
my $pid_file = $pid_dir . "octo_reporter_${pid_param}.pid";

$Session->{progress_current} = undef;
$Session->{progress_desc} = undef;
$Session->{progress_running} = undef;
$Session->{progress_total} = undef;

my $pid = Octopussy::PID_Value($pid_file);
kill USR2 => $pid;
$Response->Redirect("./reports.asp");
%>
