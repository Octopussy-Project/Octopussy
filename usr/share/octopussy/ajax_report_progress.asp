<%
use Octopussy;

my $cmd = $Request->QueryString("cmd");
my $pid = $Request->QueryString("pid");

my $reportname = $cmd;
$reportname =~ s/.+\/(.+)?" 2>.+$/$1/g;
#$reportname =~ s/.+\/(.+)?"$/$1/g;
my $report_type = $reportname;
$report_type =~ s/(.+)-\d{8}.+/$1/;
my $reportfile = $cmd;
$reportfile =~ s/.+"(.+)?" 2>.+$/$1/g;
#$reportfile =~ s/.+"(.+)?"$/$1/g;

my $pid_dir = Octopussy::Directory("running");

#my $error_file = $reportname;
#$error_file =~ s/(.+)\.(\w+)$/$1.err/;
#$error_file = $pid_dir . "octo_reporter_" . $error_file;
my $status_file = $pid_dir . "octo_reporter_" . $reportname . ".status";

#$Response->Redirect("./report_show.asp?report_type=$report_type&filename=$reportname")
#  if (-f "$reportfile");
#$Response->Redirect("./report_error.asp?file=$error_file")
#  if (-s $error_file);

my $pid_file = $pid_dir . "octo_reporter_" . $reportname . ".pid";
AAT::DEBUG("PID FILE: $pid_file");

open(FILE, "< $pid_file");
$pid = <FILE>;
close(FILE);

AAT::DEBUG("PID: $pid");

my $status = kill USR1 => $pid;
open(FILE, "cat '$status_file' |");
$status = <FILE>;
close(FILE);

my ($desc, $current, $total, $percent) = (undef, undef, undef, undef); 
if ($status =~ /(.+)\[(\d+)\/(\d+)\]/)
{
	($desc, $current, $total) = ($1, $2, $3);
	$percent = int($current*100/$total);
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<reportname><%= $reportname %></reportname>
	<pid><%= $pid %></pid>
	<desc><%= $desc %></desc>
	<current><%= $current %></current>
	<total><%= $total %></total>
	<percent><%= $percent %></percent>
</root>
