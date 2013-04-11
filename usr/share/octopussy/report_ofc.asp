<%
if (NOT_NULL($Session->{AAT_LOGIN}))
{
	my $file = $Session->{ofc_file};
	if (defined open(FILE, "<", $file))
	{ 
  		while (<FILE>)
    		{ print $_; }
  	close(FILE);
	}
}
%>
