<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<AAT:Box>
  <AAT:BoxRow>
<%
my %arg = @_;
my $max_cols = $arg{max_cols} || 10;
my $i = 1;

foreach my $e (AAT::ARRAY($arg{list}))
{
	my $value = (ref $e eq "HASH" ? $e->{value} : $e);
  my $label = (ref $e eq "HASH" ? $e->{label} : $e);
	$value = (defined $arg{name} ? $arg{name} . "_" : "") . $value;
	%><AAT:BoxCol><AAT:CheckBox name="$value" />
	<AAT:Label value="$label" /></AAT:BoxCol><%
	if ($i >= $max_cols)
  {
    $i = 0;
    %></tr><tr class="box"><%
  }
  $i++;
} 
%></AAT:BoxRow>
</AAT:Box>
