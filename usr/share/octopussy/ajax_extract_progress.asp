<%
use Octopussy;

my $pid_dir = Octopussy::Directory("running");
my $pid_param = $Session->{extracted};
my $pid_file = $pid_dir . "octo_extractor_${pid_param}.pid";
my $status_file = $pid_dir . "octo_extractor_${pid_param}.status";
my $status = "";
my ($current, $total, $match) = (undef, undef, undef);

if (-f $pid_file)
{
	my $pid = `cat "$pid_file"`;
	kill USR1 => $pid;
	($current, $total, $match) = ($Session->{extract_progress_current},
		$Session->{extract_progress_total}, $Session->{extract_progress_match});
}
if (-f $status_file)
{
	open(FILE, "cat \"$status_file\" |");
	$status = <FILE>;
	close(FILE);
	($current, $total, $match) = ($1, $2, $3)
		if ($status =~ /.+\[(\d+)\/(\d+)\] \[(\d+)\]$/);
	($Session->{extract_progress_current}, $Session->{extract_progress_total}, 
		$Session->{extract_progress_match}) = ($current, $total, $match);
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<current><%= $current %></current>
	<total><%= $total %></total>
	<match><%= $match %></match>
</root>
