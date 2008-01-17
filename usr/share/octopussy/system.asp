<WebUI:PageTop title="System" help="system_config"/>
<%
$Response->Redirect("./index.asp")	
	if ($Session->{AAT_ROLE} !~ /admin/);

my $f = $Request->Form();
my $action = $Request->QueryString("action");

#if (AAT::NOT_NULL($action) && ($action eq "backup"))
#	{ Octopussy::Configuration::Backup(); }
#elsif ((AAT::NOT_NULL($f->{file})) && (AAT::NOT_NULL($f->{restore})))
#	{ Octopussy::Configuration::Restore($f->{file}); }

if (defined $f->{submit})
{
	my %db_conf = ( database => { 
			type => $f->{"db_type"}, host => $f->{"db_host"}, 
			user => $f->{"db_user"}, password => $f->{"db_password"},
			db => $f->{"db_database"} } );
	my %ldap_conf = ( ldap => {
      contacts_base => $f->{"ldap_contacts_base"},
      contacts_filter => $f->{"ldap_contacts_filter"},
      contacts_server => $f->{"ldap_contacts_server"},
      users_base => $f->{"ldap_users_base"},
      users_filter => $f->{"ldap_users_filter"},
      users_server => $f->{"ldap_users_server"} } );
	my %nsca_conf = ( nsca => {
			bin => $f->{"nsca_bin"}, conf => $f->{"nsca_conf"},
      nagios_server => $f->{"nsca_nagios_server"},
      nagios_host => $f->{"nsca_nagios_host"},
      nagios_service => $f->{"nsca_nagios_service"} } );
	my %proxy_conf = ( proxy => {
			server => $f->{"proxy_server"},   port => $f->{"proxy_port"},
      user => $f->{"proxy_user"},       password => $f->{"proxy_password"} } );
	my %smtp_conf = ( smtp => {
			server => $f->{"smtp_server"}, sender => $f->{"smtp_sender"} } );
	my %xmpp_conf = ( xmpp => {
			server => $f->{"xmpp_server"}, tls => $f->{"xmpp_tls"},
      user => $f->{"xmpp_user"}, password => $f->{"xmpp_password"} } );
	AAT::Update_Configuration("db", \%db_conf, "aat_db");
	AAT::Update_Configuration("ldap", \%ldap_conf, "aat_ldap");
	AAT::Update_Configuration("nsca", \%nsca_conf, "aat_nsca");
	AAT::Update_Configuration("proxy", \%proxy_conf, "aat_proxy");
	AAT::Update_Configuration("smtp", \%smtp_conf, "aat_smtp");
	AAT::Update_Configuration("xmpp", \%xmpp_conf, "aat_xmpp");
	AAT::Syslog("octo_WebUI", "SYSTEM_CONFIG_MODIFIED");
}
%>
<AAT:Inc file="octo_system_configurator" action="./system.asp" />
<WebUI:PageBottom />
