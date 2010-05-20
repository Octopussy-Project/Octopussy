<WebUI:PageTop title="_STORAGES" help="storages" />
<%
my $f = $Request->Form();
my $action = $f->{action} || $Request->QueryString("action");
my $name = $f->{name} || $Request->QueryString("name");

if ($Session->{AAT_ROLE} !~ /ro/)
{
	if ($action eq "add")
	{
		if (NOT_NULL($name) && ($f->{directory} =~ /^\//))
		{
			Octopussy::Storage::Add(
				{ s_id => $name, directory => $f->{directory} } );
			AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Storage", $name);
		}
	}
	elsif ($action eq "remove")
	{
		Octopussy::Storage::Remove($name);
		AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Storage", $name);
	}
	elsif ($action eq "default")
	{
		Octopussy::Storage::Default_Set( { incoming => $f->{incoming}, 
			unknown => $f->{unknown}, known => $f->{known} } );
		AAT::Syslog::Message("octo_WebUI", "STORAGE_DEFAULT_MODIFIED");
	}
}
%>
<AAT:Message level="-1" msg="_MSG_STORAGES_DEFAULT_DIRECTORIES" />
<AAT:Inc file="octo_storages_default" url="./storages.asp" />
<AAT:Inc file="octo_storages_list" url="./storages.asp" />
<WebUI:PageBottom />
