<% 
my %arg = @_; 

my @roles = AAT::User::Roles_Configurations();

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => "user_role", list => \@roles, selected => $arg{selected}); 
%>
