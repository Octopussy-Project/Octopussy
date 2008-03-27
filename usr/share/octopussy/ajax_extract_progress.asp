<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_file = $pid_dir . "octo_extractor.pid";
my $status_file = $pid_dir . "octo_extractor.status";
my $pid = `cat "$pid_file"`;

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
	<desc><%= $desc %></desc>
	<current><%= $current %></current>
	<total><%= $total %></total>
	<percent><%= $percent %></percent>
</root>
