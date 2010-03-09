# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::SMTP - AAT SMTP module

=cut

package AAT::SMTP;

use strict;
use warnings;
use Readonly;

use Mail::Sender;
use Net::Telnet;

use AAT::Application;

Readonly my $SMTP_PORT    => 25;
Readonly my $SMTP_TIMEOUT => 3;

my %conf_file = ();

=head1 FUNCTIONS


=head2 Configuration($appli)

Returns SMTP configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'smtp');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{smtp});
}

=head2 Connection_Test($appli)

Checks the SMTP connection

=cut

sub Connection_Test
{
  my $appli  = shift;
  my $status = 0;
  my $conf   = Configuration($appli);
  if ( AAT::NOT_NULL($conf->{server})
    && AAT::NOT_NULL($conf->{sender}))
  {
    my $con = new Net::Telnet(
      Host    => $conf->{server},
      Port    => $SMTP_PORT,
      Errmode => 'return',
      Timeout => $SMTP_TIMEOUT
    );
    my $sender = (
      AAT::NOT_NULL($conf->{auth_type})
      ? new Mail::Sender {
        smtp    => $conf->{server},
        from    => $conf->{sender},
        auth    => $conf->{auth_type},
        authid  => $conf->{auth_login},
        authpwd => $conf->{auth_password}
        }
      : new Mail::Sender {smtp => $conf->{server}, from => $conf->{sender}}
    );

    if ((defined $con) && (defined $sender) && (ref $sender))
    {
      $status = 1;
      $con->close();
    }
  }

  return ($status);
}

=head2 Send_Message($appli, $msg_data)

Send message to @dests

=cut

sub Send_Message
{
  my ($appli, $msg_data) = @_;

  my $conf = Configuration($appli);
  if (AAT::NOT_NULL($conf->{server}) && AAT::NOT_NULL($conf->{sender}))
  {
    my $from    = $msg_data->{from} || $conf->{sender};
    my $subject = $msg_data->{subject};
    my $body    = $msg_data->{body};

    my $sender = (
      AAT::NOT_NULL($conf->{auth_type})
      ? new Mail::Sender {
        smtp    => $conf->{server},
        from    => $from,
        auth    => $conf->{auth_type},
        authid  => $conf->{auth_login},
        authpwd => $conf->{auth_password}
        }
      : new Mail::Sender {smtp => $conf->{server}, from => $from}
    );

    if ((defined $sender) && (ref $sender))
    {
      foreach my $dest (AAT::ARRAY($msg_data->{dests}))
      {
        if (defined $msg_data->{file})
        {
          $sender->MailFile(
            {
              to      => $dest,
              subject => $subject,
              msg     => $body,
              file    => $msg_data->{file}
            }
          );
        }
        else
        {
          $sender->MailMsg({to => $dest, subject => $subject, msg => $body});
        }
      }
      $sender->Close();

      return (1);
    }
  }
  else
  {
    AAT::Syslog('AAT_SMTP', 'SMTP_INVALID_CONFIG');
  }

  return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
