<%
my %arg = @_;

my $pattern = $arg{msg_pattern};
my $orig = $arg{msg_orig};
my $html_msg_pattern = $Server->HTMLEncode($pattern);
my $html_msg_orig = $Server->HTMLEncode($orig);
%>
<AAT:Form action="./wizard_msg.asp">
<AAT:Form_Hidden name="service" value="$arg{service}" />
<AAT:Form_Hidden name="loglevel" value="$arg{loglevel}" />
<AAT:Form_Hidden name="taxonomy" value="$arg{taxonomy}" />
<AAT:Form_Hidden name="table" value="$arg{table}" />
<AAT:Form_Hidden name="msg_orig" value="$html_msg_orig" />
<AAT:Form_Hidden name="msg_pattern" value="$html_msg_pattern" />
<AAT:Box align="center">
<%
my $re = Octopussy::Message::Short_Pattern_To_Regexp({ pattern => $pattern });
my $i = 1;
while ($pattern =~ /<\@(.+?)\@>/)
{
  $pattern =~ s/.*?(<\@([^\@]+?)\@>)//;
	my $msg_color = Octopussy::Message::Color_Without_Field($1);
	my $type = $2;
	my $selected = (($i == 1) ? "datetime" : (($i == 2) ? "device" : ""));
	%><AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="$msg_color" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Inc file="octo_selector_table_field" table="$arg{table}" 
		field_type="$type" field_number="$i" regexp="$re" orig_msg="$orig" 
		selected="$selected" />
	</AAT:BoxCol></AAT:BoxRow><%
  $i++;
}
%>
<AAT:BoxRow><AAT:BoxCol cspan="2"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol cspan="2" align="center">
	<AAT:Form_Submit value="_EDIT" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>
