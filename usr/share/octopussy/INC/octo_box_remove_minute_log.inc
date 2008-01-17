<%
my %arg = @_;
my $device = $arg{device};
my $timestamp = $arg{timestamp};
my ($y, $m, $d, $hour, $min) = ($1, $2, $3, $4, $5)
	if ($timestamp =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/);

my $dialog = "./dialog.asp?id=delete_log_minute";
my $remove_link = "$dialog&device=$device&datetime="
	. "$y%20$m%20$d%20$hour:$min&timestamp=$timestamp&action=remove_minute";
%>
<AAT:Box align="left">
<AAT:BoxRow>
<AAT:BoxCol><AAT:Button name="remove" popup_link="$remove_link" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_REMOVE_LOG_MINUTE" style="B" />
<AAT:Label value=" $y $m $d $hour:$min" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
