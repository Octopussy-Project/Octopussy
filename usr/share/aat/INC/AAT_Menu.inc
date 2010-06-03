<%
my %a = @_;
my $align = (defined $a{align} ? 
	(($a{align} =~ /^C/i) ? "center" 
		: (($a{align} =~ /^R/i) ? "right" : $a{align} )) : "left");
my $mode = AAT::Menu_Mode();
%>
<AAT:Box align="$align">
<%
foreach my $e (ARRAY($a{items}))
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
		if ((NOT_NULL($icon)) && ($mode ne "TEXT_ONLY"))
		{
			my $alt = "Icon Menu " . AAT::Translation($label);
			if (NOT_NULL($link))
			{
				if ($mode eq "ICONS_ONLY")
					{ %><AAT:IMG name="$icon" width="32" height="32" link="$link" tooltip="$label" alt="$alt" /><% }
				else
					{ %><AAT:IMG name="$icon" width="32" height="32" link="$link" alt="$alt" /><% }
			}
			elsif (NOT_NULL($p_link))
			{ 
				if ($mode eq "ICONS_ONLY")
          { %><AAT:IMG name="$icon" width="32" height="32" popup_link="$p_link" tooltip="$label" alt="$alt" /><% }
				else
					{ %><AAT:IMG name="$icon" width="32" height="32" popup_link="$p_link" alt="$alt" /><% }
			}
		}%>
		</AAT:BoxCol><AAT:BoxCol valign="middle"><%
		if ((NULL($link)) && (NULL($p_link)) && (NOT_NULL($label)) 
				&& ((NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" /><% }
		elsif ((NOT_NULL($link)) 
						&& ((NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" link="$link" /><% }
		elsif ((NOT_NULL($p_link)) 
						&& ((NULL($icon)) || ($mode ne "ICONS_ONLY")))
			{ %><AAT:Label value="$label" popup_link="$p_link" /><% }
		%></AAT:BoxCol></AAT:BoxRowMenu><%
	}
}
%>	
</AAT:Box>
