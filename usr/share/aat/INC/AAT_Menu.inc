<%
my %a = @_;
my $align = (defined $a{align} ? 
	(($a{align} =~ /^C/i) ? "center" 
		: (($a{align} =~ /^R/i) ? "right" : $a{align} )) : "left");
my $mode = AAT::Menu_Mode();
%>
<AAT:Box align="$align">
<%
foreach my $e (AAT::ARRAY($a{items}))
{
	my ($label, $link, $p_link, $icon) = 
		($e->{label}, $e->{link}, $e->{popup_link}, $e->{icon});
	if (defined $e->{separator})
	{
	%><AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow><%
	}
	else
	{
		%><AAT:BoxRowMenu><AAT:BoxCol valign="middle"><%
		if ((AAT::NOT_NULL($icon)) && ($mode ne "TEXT_ONLY"))
		{
			my $alt = "Icon Menu " . AAT::Translation($label);
			if (AAT::NOT_NULL($link))
			{
				if ($mode eq "ICONS_ONLY")
					{ %><AAT:IMG name="$icon" link="$link" tooltip="$label" alt="$alt" /><% }
				else
					{ %><AAT:IMG name="$icon" link="$link" alt="$alt" /><% }
			}
			elsif (AAT::NOT_NULL($p_link))
			{ 
				if ($mode eq "ICONS_ONLY")
          { %><AAT:IMG name="$icon" popup_link="$p_link" tooltip="$label" alt="$alt" /><% }
				else
					{ %><AAT:IMG name="$icon" popup_link="$p_link" alt="$alt" /><% }
			}
		}%>
		</AAT:BoxCol><AAT:BoxCol valign="middle"><%
		if ((AAT::NULL($link)) && (AAT::NULL($p_link)) && (AAT::NOT_NULL($label)) 
				&& ((AAT::NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" /><% }
		elsif ((AAT::NOT_NULL($link)) 
						&& ((AAT::NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" link="$link" /><% }
		elsif ((AAT::NOT_NULL($p_link)) 
						&& ((AAT::NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" popup_link="$p_link" /><% }
		%></AAT:BoxCol></AAT:BoxRowMenu><%
	}
}
%>	
</AAT:Box>
