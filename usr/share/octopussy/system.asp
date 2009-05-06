<%
$Response->Redirect("./index.asp")	
	if ($Session->{AAT_ROLE} !~ /admin/);

my $f = $Request->Form();
my $q = $Request->QueryString();
my $action = $f->{action} || $q->{action};
my $file = $f->{file} || $q->{file};
my $restored = 0;

if (AAT::NOT_NULL($action) && ($action eq "backup"))
{ 
	$file = Octopussy::Configuration::Backup(); 
	if ($file =~ /(backup_\d{12}.tgz)/)
	{
		my $filename = $1;
		AAT::File_Save( { contenttype => "archive/tar", 
			input_file => $file, output_file => $filename } );
	}
}
elsif ((AAT::NOT_NULL($file)) && ($action eq "restore"))
	{ $Response->Redirect("./dialog.asp?id=restore_config&arg1=$file"); }
elsif ((AAT::NOT_NULL($file)) && ($action eq "restore_confirmed"))
{ 
	Octopussy::Configuration::Restore($file); 
	$restored = 1;
}
%>
<WebUI:PageTop title="_SYSTEM_CONFIG" help="system_config"/>
<%
if ($restored)
{ 
	my $msg = sprintf(AAT::Translation("_MSG_CONFIG_RESTORED"), $file);
	%><AAT:Message level="0" msg="$msg" /><% 
}
if (defined $f->{config})
{
	if ($f->{config} eq "database")
	{
		my %db_conf = ( database => { type => $f->{"db_type"}, 
			host => $f->{"db_host"}, user => $f->{"db_user"}, 
			password => $f->{"db_password"}, db => $f->{"db_database"} } );
		AAT::Update_Configuration("Octopussy", "db", \%db_conf, "aat_db");
	}
	elsif ($f->{config} eq "ldap_contacts")
	{
		my $c = AAT::LDAP::Configuration("Octopussy");
		my ($server, $base, $filter) =
  		($c->{users_server}, $c->{users_base}, $c->{users_filter});
		my %ldap_conf = ( ldap => { contacts_base => $f->{"ldap_contacts_base"},
      contacts_filter => $f->{"ldap_contacts_filter"}, 
			contacts_server => $f->{"ldap_contacts_server"},
      users_base => $base, users_filter => $filter, users_server => $server } );
		AAT::Update_Configuration("Octopussy", "ldap", \%ldap_conf, "aat_ldap");
	}
	elsif ($f->{config} eq "ldap_users")
  {
		my $c = AAT::LDAP::Configuration("Octopussy");
    my ($server, $base, $filter) =
      ($c->{contacts_server}, $c->{contacts_base}, $c->{contacts_filter});
		my %ldap_conf = ( ldap => { contacts_base => $base,
      contacts_filter => $filter, contacts_server => $server,
      users_base => $f->{"ldap_users_base"},
      users_filter => $f->{"ldap_users_filter"},
      users_server => $f->{"ldap_users_server"} } );
    AAT::Update_Configuration("Octopussy", "ldap", \%ldap_conf, "aat_ldap");
	}
	elsif ($f->{config} eq "nsca")
	{
		my %nsca_conf = ( nsca => { bin => $f->{"nsca_bin"}, 
			conf => $f->{"nsca_conf"}, nagios_server => $f->{"nsca_nagios_server"},
      nagios_host => $f->{"nsca_nagios_host"}, 
			nagios_service => $f->{"nsca_nagios_service"} } );
		AAT::Update_Configuration("Octopussy", "nsca", \%nsca_conf, "aat_nsca");
	}
	elsif ($f->{config} eq "proxy")
	{
		my %proxy_conf = ( proxy => { server => $f->{"proxy_server"},
			port => $f->{"proxy_port"}, user => $f->{"proxy_user"},
			password => $f->{"proxy_password"} } );
		AAT::Update_Configuration("Octopussy", "proxy", \%proxy_conf, "aat_proxy");
	}
	elsif ($f->{config} eq "smtp")
	{
		my $auth_type = $f->{"smtp_authtype"};
		my %smtp_conf = ( smtp => { server => $f->{"smtp_server"}, 
			sender => $f->{"smtp_sender"}, 
			auth_type => ($auth_type eq "-NONE-" ? undef : $auth_type), 
			auth_login => $f->{"smtp_authlogin"}, 
			auth_password => $f->{"smtp_authpassword"} } );
		AAT::Update_Configuration("Octopussy", "smtp", \%smtp_conf, "aat_smtp");
	}
	elsif ($f->{config} eq "xmpp")
	{
		my %xmpp_conf = ( xmpp => { server => $f->{"xmpp_server"}, 
      port => $f->{"xmpp_port"}, tls => $f->{"xmpp_tls"}, 
      user => $f->{"xmpp_user"}, password => $f->{"xmpp_password"} } );
		AAT::Update_Configuration("Octopussy", "xmpp", \%xmpp_conf, "aat_xmpp");
	}
	AAT::Syslog("octo_WebUI", "SYSTEM_CONFIG_MODIFIED");
}
%>
<AAT:Inc file="octo_system_configurator" action="./system.asp" />
<WebUI:PageBottom />
