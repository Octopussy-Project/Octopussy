<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<% 
my %arg = @_; 
my @items = AAT::List::Items($arg{list});
my $nb_cols = 3;
%>
<AAT:Box title="AAT List: $arg{list}">
<AAT:BoxRow><AAT:BoxCol></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_LABEL" style="B" /></AAT:BoxCol>
<AAT:BoxCol><AAT:Label value="_VALUE" style="B" /></AAT:BoxCol>
<%
my %headers = ();
foreach my $i (@items)
{
	foreach my $k (keys %{$i})
	{
		$headers{$k} = 1	
			if (($k ne "label") && ($k ne "value") && ($k ne "logo"));	
	}
}
foreach my $k (sort keys %headers)
{
	$nb_cols++;
	$k = "_" . uc($k);
	%><AAT:BoxCol><AAT:Label value="$k" /></AAT:BoxCol><%
}
$nb_cols += 2;
%>
<AAT:BoxCol cspan="2"><AAT:Label value="_ACTION" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="$nb_cols"><hr></AAT:BoxCol></AAT:BoxRow>
<%
foreach my $i (@items)
{
	my $logo = $i->{logo};
	%><AAT:BoxRow>
	<AAT:BoxCol><%
	if (defined $logo)
		{ %><AAT:IMG name="$logo" /><% } %>
	</AAT:BoxCol>
	<AAT:BoxCol><b><%= $i->{label} %></b></AAT:BoxCol>
	<AAT:BoxCol><%= $i->{value} %></AAT:BoxCol><%
	foreach my $k (sort keys %headers)
		{ %><AAT:BoxCol><%= "test" %></AAT:BoxCol><% }
	%>
	<AAT:BoxCol><AAT:Button name="edit" tooltip="_EDIT" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="remove" tooltip="_REMOVE" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
my $nb_items = sprintf(AAT::Translation("_NB_ITEMS"), $#items+1); 
%>
<AAT:BoxRow><AAT:BoxCol cspan="$nb_cols"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="$nb_cols" align="C"><AAT:Label value="_NB_ITEMS" />
</AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
