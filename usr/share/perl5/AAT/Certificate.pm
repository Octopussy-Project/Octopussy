=head1 NAME

AAT::Certificate - AAT Certificate module

=cut

package AAT::Certificate;

use strict;

my $CA_DAYS = 3650;
my $CIPHER = "rsa:1024";

my $CONF = "/etc/aat/openssl.cnf";
my $CONF_CA = "/var/run/aat/openssl_ca.cnf";
my $CONF_CLIENT = "/var/run/aat/openssl_client.cnf";
my $CONF_SERVER = "/var/run/aat/openssl_server.cnf";

my $OPENSSL = "/usr/bin/openssl";
my $SSL_CA = "$OPENSSL ca -batch";
my $SSL_REQ = "$OPENSSL req -batch"; 
my $SSL_X509 = "$OPENSSL x509";

=head1 FUNCTIONS

=head2 Authority_Configuration()

=cut

sub Authority_Configuration($)
{
	my $appli = shift;
	my %conf = ();

	my $ca_dir = AAT::Application::Directory($appli, "certificate_authority");
	my @lines = `$SSL_X509 -text -noout -in $ca_dir/cacert.pem`;
	foreach my $line (@lines)
	{
		if ($line =~ /Subject: C=(\w+), ST=(.+?), L=(.+?), O=(.+?), OU=(.+?), CN=(.+?)\/emailAddress=(\S+)$/)
		{
			($conf{country}, $conf{state}, $conf{city}, $conf{org}, $conf{org_unit},
			$conf{common_name}, $conf{email}) = ($1, $2, $3, $4, $5, $6, $7);
		}	
	}

	return (%conf);
}

=head2 Authority_Create($appli, \%conf)

=cut

sub Authority_Create($$)
{
	my ($appli, $conf) = @_;

	my $ca_dir = AAT::Application::Directory($appli, "certificate_authority");
	`rm -rf $ca_dir`;
	`mkdir -p $ca_dir/{certs,crl,newcerts,private}`;
  `touch $ca_dir/index.txt`;
  `echo "01" > $ca_dir/serial`;

	`cp $CONF $CONF_CA.tmp`;
	open(FILE, "< $CONF_CA.tmp");
	open(OUT, "> $CONF_CA");
	while (<FILE>)
	{
		my $line = $_;
		foreach my $k (keys %{$conf})
		{
			my $sub = "<" . uc($k) . ">";
			$line =~ s/$sub/$conf->{$k}/g;
		}
		print OUT $line;
	}
	close(FILE); 
	close(OUT);
	`$SSL_REQ -config $CONF_CA -passout pass:octo -x509 -newkey $CIPHER -days $CA_DAYS -keyout $ca_dir/private/cakey.pem -out $ca_dir/cacert.pem`;
	`chmod -R 600 $ca_dir/private`;
}

=head2 Client_Create($appli, $file, $password, \%conf)

=cut

sub Client_Create($$$$)
{
	my ($appli, $file, $password, $conf) = @_;

	my $ca_dir = AAT::Application::Directory($appli, "certificate_authority");
	my $info = AAT::Application::Info($appli);
	`cp $CONF $CONF_CLIENT.tmp`;
  open(FILE, "< $CONF_CLIENT.tmp");
  open(OUT, "> $CONF_CLIENT");
  while (<FILE>)
  {
    my $line = $_;
    foreach my $k (keys %{$conf})
    {
      my $sub = "<" . uc($k) . ">";
      $line =~ s/$sub/$conf->{$k}/g;
    }
    $line =~ s/<DIR>/$ca_dir/g;
    print OUT $line;
  }
  close(FILE);
  close(OUT);
	`$SSL_REQ -config $CONF_CLIENT -passout pass:octo -newkey $CIPHER -keyout ${file}.key -out ${file}.req`;
	`$SSL_CA -config $CONF_CLIENT -passin pass:octo -in ${file}.req -out ${file}.pem`;
  `$OPENSSL pkcs12 -export -passin pass:octo -passout pass:$password -in ${file}.pem -inkey ${file}.key -out ${file}.p12 -name "$conf->{common_name}"`;
	`chown $info->{user}: ${file}.p12`;
}

=head2 Server_Create()

=cut

sub Server_Create
{
	my ($appli, $dest, $conf) = @_;

	my $ca_dir = AAT::Application::Directory($appli, "certificate_authority");	
	my $info = AAT::Application::Info($appli);
	`cp $CONF $CONF_SERVER.tmp`;
  open(FILE, "< $CONF_SERVER.tmp");
  open(OUT, "> $CONF_SERVER");
  while (<FILE>)
  {
    my $line = $_;
    foreach my $k (keys %{$conf})
    {
      my $sub = "<" . uc($k) . ">";
      $line =~ s/$sub/$conf->{$k}/g;
    }
		$line =~ s/<DIR>/$ca_dir/g;
    print OUT $line;
  }
  close(FILE);
  close(OUT);
	`$SSL_REQ -config $CONF_SERVER -newkey $CIPHER -keyout $dest/server.key -out $dest/server.req`;
	`$SSL_CA -config $CONF_SERVER -in $dest/server.req -out $dest/server.crt`;
	`$OPENSSL rsa -passout pass:octo -in $dest/server.key -out $dest/server.key`;
	`chown $info->{user}: $dest/*`;
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
