<WebUI:PageTop title="Wizard Message" />
<%
my $device = $Request->Form("device");
$device = (Octopussy::Device::Valid_Name($device) ? $device : undef);
my $msg_orig = $Request->Form("msg_orig");
my $msg_pattern = $Request->Form("msg_pattern");
my $service = $Request->Form("service");
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
my $loglevel = $Request->Form("loglevel");
$loglevel = (Octopussy::Loglevel::Valid_Name($loglevel) ? $loglevel : undef);
my $taxonomy = $Request->Form("taxonomy");
$taxonomy = (Octopussy::Taxonomy::Valid_Name($taxonomy) ? $taxonomy : undef);
my $table = $Request->Form("table");
$table = (Octopussy::Table::Valid_Name($table) ? $table : undef);
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
