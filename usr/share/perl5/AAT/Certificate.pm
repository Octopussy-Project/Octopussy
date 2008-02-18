=head1 NAME

AAT::Certificate - AAT Certificate module

=cut

package AAT::Certificate;

use strict;

my $CA_DAYS = 3650;
my $CIPHER = "rsa:1024";

my $CONF = "/etc/aat/openssl.cnf";
my $CONF_CA = "/var/run/aat/openssl_ca.cnf";
my $CONF_SERVER = "/var/run/aat/openssl_server.cnf";

my $OPENSSL = "/usr/bin/openssl";
my $SSL_CA = "$OPENSSL ca";
my $SSL_REQ = "$OPENSSL req"; 

=head1 FUNCTIONS

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
	`$SSL_REQ -batch -config $CONF_CA -passout pass:octo -x509 -newkey $CIPHER -days $CA_DAYS -keyout $ca_dir/private/cakey.pem -out $ca_dir/cacert.pem`;
	`chmod -R 600 $ca_dir/private`;
}


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
	`$SSL_REQ -batch -config $CONF_SERVER -newkey $CIPHER -keyout $dest/server.key -out $dest/server.req`;
	`$SSL_CA -batch -config $CONF_SERVER -in $dest/server.req -out $dest/server.crt`;
	`$OPENSSL rsa -passout pass:octo -in $dest/server.key -out $dest/server.key`;
	`chown $info->{user}: $dest/*`;
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
