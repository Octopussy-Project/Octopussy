<%
my %a = @_;
my $align = (defined $a{align} ? 
	(($a{align} =~ /^C/i) ? "center" 
		: (($a{align} =~ /^R/i) ? "right" : $a{align} )) : "left");
%>
<AAT:Box align="$align">
<%
foreach my $e (AAT::ARRAY($a{items}))
{
	my ($label, $link, $popup_link, $icon) = 
		($e->{label}, $e->{link}, $e->{popup_link}, $e->{icon});
	if (defined $e->{separator})
	{
	%><AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow><%
	}
	else
	{
		%><AAT:BoxRowMenu><AAT:BoxCol valign="center"><%
		if ((defined $icon) && ($icon ne ""))
		{
			my $alt = "Icon Menu " . AAT::Translation($label);
			%><AAT:IMG name="$icon" link="$link" alt="$alt" /><%
		}%>
		</AAT:BoxCol><AAT:BoxCol valign="center"><%
		if ((AAT::NULL($link)) && (AAT::NULL($popup_link)) 
				&& (AAT::NOT_NULL($label)))
		{
			%><AAT:Label value="$label" /><%
		}
		elsif (AAT::NOT_NULL($link))
		{
			%><AAT:Label value="$label" link="$link" /><%
		}
		elsif (AAT::NOT_NULL($popup_link))
		{
			%><AAT:Label value="$label" popup_link="$popup_link" /><%
		}
		%></AAT:BoxCol></AAT:BoxRowMenu><%
	}
}
%>	
</AAT:Box>
