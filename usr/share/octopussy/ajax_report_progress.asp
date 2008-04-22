<%
use Octopussy;

my $cmd = $Request->QueryString("cmd");
my $reportname = $cmd;
$reportname =~ s/.+\/(.+)?.$/$1/g; 
my $report_type = $reportname;
$report_type =~ s/(.+)-\d{8}.+/$1/;
my $reportfile = $cmd;
$reportfile =~ s/.+"(.+)?"$/$1/g;
my $pid_dir = Octopussy::Directory("running");
my $status_file = $pid_dir . "octo_reporter_${reportname}.status";
my $pid_file = $pid_dir . "octo_reporter_${reportname}.pid";
my $status = "";
my ($desc, $current, $total, $percent) = (undef, undef, undef, undef);

if (-f $pid_file)
{
	my $pid = `cat "$pid_file"`;
	kill USR1 => $pid;
}
f (-f $status_file)
{
	open(FILE, "cat \"$status_file\" |");
	$status = <FILE>;
	close(FILE);
	($desc, $current, $total) = ($1, $2, $3)
		if ($status =~ /(.+)\[(\d+)\/(\d+)\]/);
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<reportname><%= $reportname %></reportname>
	<desc><%= $desc %></desc>
	<current><%= $current %></current>
	<total><%= $total %></total>
</root>
