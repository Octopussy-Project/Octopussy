<WebUI:PageTop title="System" help="system_config"/>
<%
$Response->Redirect("./index.asp")	
	if ($Session->{AAT_ROLE} !~ /admin/);

my $f = $Request->Form();
my $action = $Request->QueryString("action");

if (AAT::NOT_NULL($action) && ($action eq "backup"))
	{ Octopussy::Configuration::Backup(); }
elsif ((AAT::NOT_NULL($f->{file})) && (AAT::NOT_NULL($f->{restore})))
	{ Octopussy::Configuration::Restore($f->{file}); }

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
		my %smtp_conf = ( smtp => { server => $f->{"smtp_server"}, 
			sender => $f->{"smtp_sender"} } );
		AAT::Update_Configuration("Octopussy", "smtp", \%smtp_conf, "aat_smtp");
	}
	elsif ($f->{config} eq "xmpp")
	{
		my %xmpp_conf = ( xmpp => { server => $f->{"xmpp_server"}, 
			tls => $f->{"xmpp_tls"}, user => $f->{"xmpp_user"}, 
			password => $f->{"xmpp_password"} } );
		AAT::Update_Configuration("Octopussy", "xmpp", \%xmpp_conf, "aat_xmpp");
	}
	AAT::Syslog("octo_WebUI", "SYSTEM_CONFIG_MODIFIED");
}
%>
<AAT:Inc file="octo_system_configurator" action="./system.asp" />
<WebUI:PageBottom />
