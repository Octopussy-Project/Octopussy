=head1 NAME

AAT::XMPP - AAT XMPP module

(Extensible Messaging and Presence Protocol (Jabber))

=cut
package AAT::XMPP;

use strict;

use Net::XMPP;

my $XMPP_FILE = undef;

=head1 FUNCTIONS

=head2 Configuration()

Returns the XMPP configuration

=cut
sub Configuration
{
	$XMPP_FILE ||= AAT::File("xmpp");
	my $conf = AAT::XML::Read($XMPP_FILE, 1);

	return ($conf->{xmpp});
}

=head2 Connection_Test()

Checks the XMPP Connection

=cut
sub Connection_Test
{
  my $status = 0;

	AAT::DEBUG("XMPP Connection::Test Begin");
	my $xmpp_conf = Configuration();
  my $client = new Net::XMPP::Client();
  my @res = $client->Connect(hostname => $xmpp_conf->{server}, 
		port => 5222, tls => $xmpp_conf->{tls}, timeout => 3);
	if (@res)
	{
		my @res = $client->AuthSend(username => $xmpp_conf->{user}, 
			password => $xmpp_conf->{password}, resource => "resource" );
		$status = 1	
			if ((\@res == 0) || ((@res == 1 && $res[0]) || $res[0] eq 'ok'));
	}
	AAT::DEBUG("XMPP Connection::Test End");

	return ($status);
}

=head2 Send_Message($msg, @dests)

Sends message '$msg' to '@dests' through XMPP

=cut
sub Send_Message
{
  my ($msg, @dests) = @_;

	my $xmpp_conf = Configuration();
	my $client = new Net::XMPP::Client();
	my @res = $client->Connect(hostname => $xmpp_conf->{server}, 
		port => 5222, tls => $xmpp_conf->{tls});
	if (@res)
	{
		$client->AuthSend('hostname' => $xmpp_conf->{server},
        'username' => $xmpp_conf->{user},
        'password' => $xmpp_conf->{password}, resource => 'resource' );
		foreach my $dest (@dests)
  	{
			$client->MessageSend('to' => $dest, 'body' => "$msg")
    		if (AAT::NOT_NULL($dest));
		}	
		sleep 1;
		$client->Disconnect();
	}
	else
  {
    AAT::Syslog("AAT::XMPP", "XMPP_INVALID_CONFIG");
  }
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
