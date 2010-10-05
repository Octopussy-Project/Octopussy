# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::XMPP - AAT XMPP module

(Extensible Messaging and Presence Protocol (Jabber))

=head1 BUGS

Net::XMPP is buggy with OpenFire & TLS
-> comment 3 lines in Net::XMPP::Protocol (approx. line 1800) 
& disable TLS:

#if($self->{STREAM}->GetStreamFeature($self->GetStreamID(),
# "xmpp-sasl"))
#{
#    return $self->AuthSASL(%args);
#}

=cut

package AAT::XMPP;

use strict;
use warnings;
use Readonly;

use Net::XMPP;

use AAT::Application;
use AAT::Syslog;
use AAT::Utils qw( NOT_NULL );
use AAT::XML;

Readonly my $XMPP_TIMEOUT => 3;

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns the XMPP configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'xmpp');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{xmpp});
}


=head2 Configuration($appli)

Returns '1' if XMPP is configured (server & port) else '0'

=cut

sub Configured
{
	my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'xmpp');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);
  
  return ((defined $conf->{server} && defined $conf->{port}) ? 1 : 0);
}


=head2 Connection_Test($appli)

Checks the XMPP Connection

=cut

sub Connection_Test
{
  my $appli  = shift;
  my $status = 0;

  my $conf_xmpp = Configuration($appli);
  if (NOT_NULL($conf_xmpp->{server}))
  {
    my $client = new Net::XMPP::Client();
    my @res    = $client->Connect(
      hostname => $conf_xmpp->{server},
      port     => $conf_xmpp->{port},
      tls      => $conf_xmpp->{tls},
      timeout  => $XMPP_TIMEOUT,
    );
    if (@res)
    {
      my @res = $client->AuthSend(
        username => $conf_xmpp->{user},
        password => $conf_xmpp->{password},
        resource => 'resource'
      );
      $status = 1
        if ((\@res == 0)
        || ((@res == 1 && $res[0]) || $res[0] eq 'ok'));
    }
  }

  return ($status);
}

=head2 Send_Message($appli, $msg, @dests)

Sends message '$msg' to '@dests' through XMPP

=cut

sub Send_Message
{
  my ($appli, $msg, @dests) = @_;

  my $conf_xmpp = Configuration($appli);
  my $client    = new Net::XMPP::Client();
  my @res       = $client->Connect(
    hostname => $conf_xmpp->{server},
    port     => $conf_xmpp->{port},
    tls      => $conf_xmpp->{tls}
  );
  if (@res)
  {
    $client->AuthSend(
      'hostname' => $conf_xmpp->{server},
      'username' => $conf_xmpp->{user},
      'password' => $conf_xmpp->{password},
      resource   => 'resource'
    );
    foreach my $dest (@dests)
    {
      if (NOT_NULL($dest))
      {
        $client->MessageSend('to' => $dest, 'body' => "$msg");
      }
    }
    sleep 1;
    $client->Disconnect();

    return (1);
  }
  else
  {
    AAT::Syslog::Message('AAT_XMPP', 'XMPP_INVALID_CONFIG');
  }

  return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
