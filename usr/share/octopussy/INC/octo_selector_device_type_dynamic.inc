<% my %arg = @_; %>
<select <%= (defined $arg{multiple} ? "multiple " : "") %> <%= (defined $arg{size} ? "size=$arg{size} " : "") %> name="device_type"
  onchange="update_device_model<%= (defined $arg{any} ? "_any" : "") %>(this.options.selectedIndex)">
<%
my @list = (defined $arg{any} ? ("-ANY-") : ());
push(@list, Octopussy::Device::Types());
foreach my $e (@list)
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $e,
		selected => ($arg{selected} eq $e ? "selected" : ""),
		label => AAT::Translation($e) );
} %>
</select>
