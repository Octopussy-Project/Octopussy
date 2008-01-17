<% 
my %arg = @_; 

my @fields = Octopussy::Message::Fields($arg{service}, $arg{msg_id});
my @list = ();
foreach my $f (@fields)
{
	push(@list, { label => "$f->{name} ($f->{type})", value => $f->{name} });
}
$Response->Include('AAT/INC/AAT_Selector.inc', 
	name => ($arg{name} || "message_field"), list => \@list);
%>
