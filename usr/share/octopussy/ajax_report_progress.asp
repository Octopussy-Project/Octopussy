<%
use Octopussy;

my $cmd = $Request->QueryString("cmd");
my $reportname = $cmd;
$reportname =~ s/.+\/(.+)?"$/$1/g;
my $report_type = $reportname;
$report_type =~ s/(.+)-\d{8}.+/$1/;
my $reportfile = $cmd;
$reportfile =~ s/.+"(.+)?"$/$1/g;

my $pid_dir = Octopussy::Directory("running");
my $status_file = $pid_dir . "octo_reporter_" . $reportname . ".status";

my $pid_file = $pid_dir . "octo_reporter_" . $reportname . ".pid";
$pid = `cat "$pid_file"`;

my $status = "";
kill USR1 => $pid;
open(FILE, "cat \"$status_file\" |");
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
