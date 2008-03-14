<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

#use utf8;
use Octopussy;

my $w = $arg{width};
my $bicolor = (defined $arg{bicolor} ? 1 : 0);
%>
<table cellspacing="0" cellpadding="0"<%= (defined $w ? " width=$w" : "") %>>
<tr>
<td class="box-top-left"></td>
<td class="boxtop"></td>
<td class="box-top-right"></td>
</tr>
<tr>
<td class="box-left"></td>
<td class="box">
<table cellspacing="0" cellpadding="2" width="100%">
<%
my $i = 0;
foreach my $row (@{$arg{elements}})
{%>
	<tr class="<%= (($bicolor && $i>=4)? (($i%2) ? "boxcolor1" : "boxcolor2") : "box") %>"><%
	foreach my $e (@{$row})
	{
		my $align = (defined $e->{align} ? " align=\"$e->{align}\"" : "");
		my $valign = (defined $e->{valign} ? " align=\"$e->{valign}\"" : "");
		my $cspan = (defined $e->{colspan} ? " colspan=$e->{colspan}" : "");
		my $rspan = (defined $e->{rowspan} ? " rowspan=$e->{rowspan}" : "");
		my $icon = (defined $e->{icon} ? "<img src=\"IMG/devices/$e->{icon}\" width=24 height=24>" : "");
		if (defined $e->{type})
		{
			my @data = ();
     	foreach my $k (keys %{$e->{args}})
      	{ push(@data, $k => $e->{args}->{$k}); }
			if ($e->{type} =~ /^form$/i)
			{
				my $method = $e->{args}->{method};
				my $action = $e->{args}->{action};
				%><form method="<%= $method %>" action="<%= $action %>"><%
			}
			elsif ($e->{type} =~ /^end_form$/i)
				{ %></form><% }
			elsif ($e->{type} =~ /^AAT_Form_Hidden$/i)
			{
				if ($e->{type} =~ /^AAT_/)
					{ $Response->Include("AAT/INC/$e->{type}.inc", @data); }
				else
					{ $Response->Include("INC/$e->{type}.inc", @data); }
			}
			else
			{
				$Response->Include("INC/box_td.inc", 
					align => $align, valign => $valign,  
					cspan => $cspan, rspan => $rspan );
				if ($e->{type} =~ /^AAT_/)
          { $Response->Include("AAT/INC/$e->{type}.inc", @data); }
        else
          { $Response->Include("INC/$e->{type}.inc", @data); }
				print "</td>";
			}
		}
		else
		{
			$Response->Include("INC/box_td.inc",
      	align => $align, valign => $valign,
       	cspan => $cspan, rspan => $rspan );
			print $icon	if (defined $icon);
			$Response->Include("AAT/INC/AAT_Label.inc", 
				value => $e->{label}, tooltip => $e->{tooltip}, 
				no_trans => $e->{no_trans}, color => $e->{color}, 
				size => $e->{size}, style => $e->{style}, 
				link => $e->{link}, link_new => $e->{link_new}, 
				popup_link => $e->{popup_link}, 
				close_popup_link => $e->{close_popup_link});
			print "</td>";
		}
	}
	%></tr><%
	$i++;
}
%>
</table>
</td>
<td class="box-right"></td></tr>
<tr>
<td class="box-bottom-left"></td>
<td class="box-bottom"></td>
<td class="box-bottom-right"></td>
</tr>
</table>
