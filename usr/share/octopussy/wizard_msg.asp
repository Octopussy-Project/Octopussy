<WebUI:PageTop title="Wizard Message" />
<%
my $device = $Request->Form("device");
my $msg_orig = $Request->Form("msg_orig");
my $msg_pattern = $Request->Form("msg_pattern");
my $service = $Request->Form("service");
my $loglevel = $Request->Form("loglevel");
my $taxonomy = $Request->Form("taxonomy");
my $table = $Request->Form("table");
my $table_field = $Request->Form("table_field_1");
my $orig = $msg_orig;

if (defined $table_field)
{
	my %tf = %{{ map { $_->{title} => $_->{type} } Octopussy::Table::Fields($table) }};
	my $i = 1;
	while ($msg_pattern =~ /<\@([^:]+?)\@>/)
	{
  		my $field = $Request->Form("table_field_$i");
		if ($field =~ /^CONST (.+)$/)
		{
			my $constant = $1;
			$msg_pattern =~ s/(.*?)<\@([^:]+?)\@>/$1$constant/;
		}
		else
		{
			my $type = $tf{$field};
			if ($type !~ /DATETIME/)
				{ $msg_pattern =~ s/(.*?)<\@([^:]+?)\@>/$1<\@$type:$field\@>/; }
			else
				{ $msg_pattern =~ s/(.*?)<\@([^:]+?)\@>/$1<\@$2:$field\@>/; }
		}
  		$i++;
	}
	%><AAT:Inc file="octo_wizard_msg_edit" device="$device" 
	service="$service" loglevel="$loglevel" 
	taxonomy="$taxonomy" table="$table"
      msg_orig="$msg_orig" msg_pattern="$msg_pattern" /><%
}
else
{
	%><AAT:Inc file="octo_wizard_msg" service="$service"
	loglevel="$loglevel" taxonomy="$taxonomy" table="$table"
  	msg_orig="$msg_orig" msg_pattern="$msg_pattern" />
  	<AAT:Inc file="octo_wizard_msg_fields" device="$device"
	service="$service" loglevel="$loglevel" 
	taxonomy="$taxonomy" table="$table"
    msg_orig="$msg_orig" msg_pattern="$msg_pattern" /><%
}
%>
<WebUI:PageBottom />
