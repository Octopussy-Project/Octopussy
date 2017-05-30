package AAT::SMTP;

=head1 NAME

AAT::SMTP - AAT SMTP module

=cut

use strict;
use warnings;

use Authen::SASL;
use Email::MIME;
use Email::Sender;
use Email::Sender::Simple;
use Email::Sender::Transport::SMTP;
use Net::Telnet;
use Path::Tiny;

use AAT::Application;
use AAT::Syslog;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;

my $SMTP_PORT    = 25;
my $SMTP_TIMEOUT = 3;

my %conf_file = ();

=head1 SUBROUTINES

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
    my $appli = shift;

    my $status = 0;
    my $conf   = Configuration($appli);
    if (   NOT_NULL($conf->{server})
        && NOT_NULL($conf->{sender}))
    {
        my $con = Net::Telnet->new(
            Host    => $conf->{server},
            Port    => $conf->{port} || $SMTP_PORT,
            Errmode => 'return',
            Timeout => $SMTP_TIMEOUT
        );
        my $transport = Email::Sender::Transport::SMTP->new(
            {
                host => $conf->{server},
                port => $conf->{port} || $SMTP_PORT,
            }
        );
        if ((defined $con) && (defined $transport) && (ref $transport))
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

    my $conf = (ref $appli ? $appli : Configuration($appli));

    if (NOT_NULL($conf->{server}) && NOT_NULL($conf->{sender}))
    {
        my $from    = $msg_data->{from} || $conf->{sender};
        my $subject = $msg_data->{subject};
        my $body    = $msg_data->{body};

        my $smtp_conf = (
            NOT_NULL($conf->{auth_login})
            ? {
                host          => $conf->{server},
                port          => $conf->{port} || $SMTP_PORT,
                sasl_username => $conf->{auth_login},
                sasl_password => $conf->{auth_password}
              }
            : {
                host => $conf->{server},
                port => $conf->{port} || $SMTP_PORT,
              }
        );
        my $transport = Email::Sender::Transport::SMTP->new($smtp_conf);

        if (defined $transport)
        {
			my $part_body = Email::MIME->create(body => $body  || 'Your Body');
			my $part_attachment = (defined $msg_data->{file} 
				? Email::MIME->create(
            		body => path($msg_data->{file})->slurp_raw,
           			attributes => {
              			filename => $msg_data->{file}, 
              			content_type => 'image/gif',
				encoding => 'base64',
                 		},
               		)
				: undef);
            foreach my $dest (ARRAY($msg_data->{dests}))
            {
				my $email = Email::MIME->create(
                	header => [
                    	To => $dest,
                    	From => $from,
						Subject => $subject || 'Your Subject',
                    	],
                	parts => [
                    	$part_body,
                    	$part_attachment,
                		],
                	);
		Email::Sender::Simple->try_to_send(
			$email, { transport => $transport });
=head2 comment
                    $stuffer->transport($transport)->to($dest)->from($from)
                        ->subject($subject || 'Your Subject')
                        ->text_body($body  || 'Your Body')
                        ->attach_file($msg_data->{file})->send();
                }
                else
                {
                    $stuffer->transport($transport)->to($dest)->from($from)
                        ->subject($subject || 'Your Subject')
                        ->text_body($body  || 'Your Body')->send();
                }
=cut
            }

            return (1);
        }
    }
    else
    {
        AAT::Syslog::Message('AAT_SMTP', 'SMTP_INVALID_CONFIG');
    }

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut
