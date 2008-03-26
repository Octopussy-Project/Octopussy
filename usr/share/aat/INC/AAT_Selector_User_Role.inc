<% 
my %arg = @_; 

my @roles = AAT::User::Roles_Configurations($arg{appli});

$Response->Include('AAT/INC/AAT_Selector.inc',
	name => "user_role", list => \@roles, selected => $arg{selected}); 
%>
