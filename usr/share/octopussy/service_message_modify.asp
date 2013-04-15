<%
$Response->Redirect("./login.asp?redirect=/services.asp")
	if (NULL($Session->{AAT_LOGIN}));
my @errors = ();
my $f = $Request->Form();
my ($loglevel, $table, $taxonomy, $service, $rank) = 
	($f->{loglevel}, $f->{table}, $f->{taxonomy}, $f->{service}, $f->{rank});
$loglevel = (Octopussy::Loglevel::Valid_Name($loglevel) ? $loglevel : undef);
$taxonomy = (Octopussy::Taxonomy::Valid_Name($taxonomy) ? $taxonomy : undef);
$table = (Octopussy::Table::Valid_Name($table) ? $table : undef);
$service = (Octopussy::Service::Valid_Name($service) ? $service : undef);
$rank = (($rank =~ /^\d+$/) ? $rank : undef);

$Response->Redirect("./services.asp")
	if (NULL($service) || NULL($table) || NULL($loglevel) || NULL($taxonomy) 
		|| NULL($rank));

my %mconf = ( msg_id => "$f->{msgid_begin}:$f->{msgid_end}", 
	loglevel => $loglevel, rank => $rank, 
	taxonomy => $taxonomy, table => $table, 
	pattern => $f->{msg_pattern} );

push(@errors, Octopussy::Service::Modify_Message($service, $f->{old_msgid},
	\%mconf))	if ($Session->{AAT_ROLE} =~ /^(admin|rw)$/i); 

if (scalar(@errors))
{
  %><AAT:Box align="C"><%
  foreach my $e (@errors)
  {
    %><AAT:BoxRow><AAT:BoxCol>
    <AAT:Message level="2" msg="$e" />
    </AAT:BoxCol></AAT:BoxRow><%
  }
  %></AAT:Box><%
}
else
{
	$Response->Redirect("./services.asp?service=$service");
}
%>
