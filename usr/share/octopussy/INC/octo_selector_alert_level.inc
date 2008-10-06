<%
my %arg = @_;
my $name = $arg{name} || "level";
my @list = Octopussy::Alert::Levels();
%>
<AAT:Selector name="$name" selected="$arg{selected}" list=\@list />
