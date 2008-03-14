<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<WebUI:PageTop title="Service Group Edition" help="#servicegroups_page" />
<%
my $f = $Request->Form();
my $servicegroup = $f->{servicegroup} || $Request->QueryString("servicegroup");
my $service = $f->{service} || $Request->QueryString("service");
my $action = $Request->QueryString("action");

if ((defined $servicegroup) && ($Session->{AAT_ROLE} !~ /ro/i))
{
  if ($action eq "remove")
  { 
		Octopussy::ServiceGroup::Remove_Service($servicegroup, $service);  
	}
  elsif ((($action eq "up") || ($action eq "down"))
          && ($Session->{AAT_ROLE} !~ /ro/i))
 	{ 	
		Octopussy::ServiceGroup::Move_Service($servicegroup, $service, $action);
 	}
  elsif (AAT::NOT_NULL($service))
    { Octopussy::ServiceGroup::Add_Service($servicegroup, $service); }
}
%>
<AAT:Inc file="servicegroup_edit" url="./servicegroup_edit.asp"
	servicegroup="$servicegroup" sort="$msg_sort" />
<WebUI:PageBottom />
