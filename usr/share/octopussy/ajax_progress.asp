<%
use Octopussy;

my $bin = $Request->QueryString("bin");
my $status = Octopussy::Status_Progress($bin, $Session->{progress_running});

if (($bin eq "octo_reporter") && ($status =~ /(.+)\[(\d+)\/(\d+)\]/))
{
	($Session->{progress_desc}, $Session->{progress_current},
		$Session->{progress_total}) = ($1, $2, $3);
}
elsif (($bin eq "octo_extractor") && ($status =~ /.+\[(\d+)\/(\d+)\] \[(\d+)\]$/))
{
	($Session->{progress_desc}, $Session->{progress_current}, 
		$Session->{progress_total}, $Session->{progress_match}) 
		= ("extracting", $1, $2, $3);
}
%>
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<desc><%= (NOT_NULL($status) ? $Session->{progress_desc} : "...") %></desc>
	<current><%= $Session->{progress_current} %></current>
	<total><%= $Session->{progress_total} %></total>
	<match><%= $Session->{progress_match} %></match>
</root>
